# kanata.nix
#
# Purpose: Run kanata as a user systemd service with hjkl mouse-emulation layer
#
# This module:
# - Installs the kanata-with-cmd package (needed for notify-send toggle alerts)
# - Writes the kanata configuration to ~/.config/kanata/kanata.kbd
# - Runs kanata via a user systemd service that follows the graphical session
# - Validates the config at Nix build time so syntax errors fail the rebuild
#   before they can fail the service at runtime
#
# Toggle: Super+C toggles a hjkl mouse layer (vim-style: h/j/k/l = left/down/up/right)
# Buttons: space = left-click, f = right-click, d = middle-click
# Scroll: u/i = up/down
#
# System-side dependency: services.kanataUdev.enable must be set so the
# kanata process can open /dev/uinput.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kanata;

  kanataConfig = ''
    ;; hjkl mouse-emulation layer.
    ;;
    ;; Entry: Super+C (chord). Tapping C alone still types a c.
    ;; Exit:  plain c or Esc from the mouse layer (ergonomic: same finger
    ;;         as movement). Super+C from mouse mode falls through and
    ;;         re-enters; noise but functional.
    ;; Each transition fires a desktop notification listing the active
    ;; keybinds as a reminder.
    ;;
    ;; Mouse layer keys:
    ;;   h / j / k / l  - cursor movement (accelerates while held)
    ;;   space          - left click (hold to drag)
    ;;   f              - right click
    ;;   d              - middle click
    ;;   u / i          - scroll up / down
    ;;
    ;; Force exit: hold left Ctrl + Space + Escape.

    (defcfg
      process-unmapped-keys yes
      danger-enable-cmd yes
      ;; movemouse-inherit-accel-state yes: qmk-like, new directions jump to max
      ;;   speed instantly. Feels like adding a direction doubles speed.
      ;; movemouse-inherit-accel-state no : new directions ramp from min, so
      ;;   diagonals grow gradually over accelTime. Smoother feel.
      movemouse-inherit-accel-state no
      movemouse-smooth-diagonals yes
      linux-continue-if-no-devs-found yes
    )

    (defsrc
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \    esc
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft z    x    c    v    b    n    m    ,    .    /    rsft
      lctl lmet lalt           spc            ralt rmet rctl
    )

    ;; Mouse movement: fixed speed (no acceleration).
    ;; Interval 8 ms (125 Hz). Distance 12 px per tick = 1500 px/s.
    ;; LShift on the mouse layer is bound to (movemouse-speed 150), which
    ;; multiplies the distance by 1.5 while held (kanata docs: "expanding
    ;; or shrinking min_distance and max_distance while the action key is
    ;; pressed"). Effective boost: 18 px/tick = 2250 px/s.
    ;; Scroll: LShift boost implemented via fork on (lsft), since
    ;; movemouse-speed only affects movemouse/movemouse-accel, not mwheel.
    (defalias
      mmu      (movemouse-up    8 12)
      mmd      (movemouse-down  8 12)
      mml      (movemouse-left  8 12)
      mmr      (movemouse-right 8 12)
      mwu      (mwheel-up   50 120)
      mwd      (mwheel-down 50 120)
      mwu-fast (mwheel-up   50 180)
      mwd-fast (mwheel-down 50 180)
    )

    ;; Layer transitions: enter or exit mouse mode + post a notification.
    ;; Calling mse-on while already on mouse is a no-op (layer-switch to
    ;; current layer). Calling mse-off from default is also a no-op, so the
    ;; plain-Esc exit on the mouse layer is safe to fire from anywhere.
    (defalias
      mse-on (multi
        (layer-switch mouse)
        (cmd notify-send "Kanata: mouse ON" "h/j/k/l move  |  spc L-click  |  f R-click  |  g M-click  |  u scroll-up  |  d scroll-down  |  x or Esc exit" -t 5000 -u normal))
      ;; mse-off retained for Super+C re-entry from mouse layer (the fork
      ;; on default layer's c position falls through to default's @tog-c
      ;; when pressed from mouse mode, which fires mse-on; mse-off unused
      ;; at the moment).
      mse-off (multi
        (layer-switch default)
        (cmd notify-send "Kanata: mouse OFF" "Super+C to re-enter" -t 5000 -u low))
      ;; Super+C: enter mouse mode. fork with lmet as trigger so plain C still
      ;; types a c.
      tog-c (fork c @mse-on (lmet)))

    ;; Default layer uses deflayermap (input->action pairs) instead of
    ;; positional deflayer columns. Only the c position is overridden;
    ;; all other keys implicitly use their defsrc value (the literal key).
    ;; c is bound to a fork so plain C still types c, but Super+C triggers
    ;; mse-on (the mouse layer's entry).
    (deflayermap (default)
      c @tog-c
    )

    ;; Mouse layer overrides:
    ;;   h j k l  - movemouse-accel-{left,down,up,right}
    ;;   spc      - mlft (hold to drag)
    ;;   f        - mrgt
    ;;   g        - mmid
    ;;   u        - mwheel-up  (50ms/120 units per activation)
    ;;   d        - mwheel-down
    ;;   x        - (layer-switch default) -- exit
    ;;   esc      - (layer-switch default) -- exit
    ;;
    ;; x and esc use direct layer-switch (not the mse-off multi) because
    ;; multi(layer-switch, cmd) has documented ordering bugs that swallow
    ;; the layer change. Trade-off: no OFF notification on exit.
    ;;
    ;; All other keys (including c, which falls through to default's
    ;; @tog-c, so Super+C from mouse layer still works) implicitly use
    ;; their defsrc value via the _ wildcard (matches unmapped keys).
    (deflayermap (mouse)
      h    @mml
      j    @mmd
      k    @mmu
      l    @mmr
      spc  mlft
      f    mrgt
      g    mmid
      u    (fork @mwu @mwu-fast (lsft))
      d    (fork @mwd @mwd-fast (lsft))
      x    (layer-switch default)
      esc  (layer-switch default)
      ;; lsft position: (movemouse-speed 150) boosts hjkl 1.5x while held.
      ;; The fork on u/d above handles the 1.5x boost for scroll, since
      ;; movemouse-speed does not affect mwheel.
      lsft (movemouse-speed 150)
    )
  '';

  kanataConfigFile = pkgs.writeTextFile {
    name = "kanata.kbd";
    text = kanataConfig;
    checkPhase = ''
      ${lib.getExe pkgs.kanata-with-cmd} --cfg "$target" --check
    '';
  };
in
{
  options.programs.kanata = {
    enable = lib.mkEnableOption "kanata hjkl mouse-emulation layer (requires services.kanataUdev.enable)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.kanata-with-cmd ];

    home.file.".config/kanata/kanata.kbd".source = kanataConfigFile;

    systemd.user.services.kanata = {
      Unit = {
        Description = "kanata hjkl mouse-emulation remapper";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Documentation = "https://github.com/jtroo/kanata";
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.kanata-with-cmd} --cfg %h/.config/kanata/kanata.kbd";
        # ExecReload sends SIGTERM which triggers the Restart=always below.
        # Kanata does not live-reload on SIGUSR1 (only on the lrld action
        # via TCP), so we do a full restart when the kbd file changes.
        ExecReload = "${pkgs.coreutils}/bin/kill -TERM $MAINPID";
        Restart = "always";
        RestartSec = "5s";
        # When the kbd file changes (after rebuild, even if the service
        # definition is unchanged), trigger a reload -> TERM -> restart.
        # XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS are inherited from
        # the user session so notify-send reaches the notification daemon.
        reloadTriggers = [ "%h/.config/kanata/kanata.kbd" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
