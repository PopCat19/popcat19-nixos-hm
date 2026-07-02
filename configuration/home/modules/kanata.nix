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

    ;; Mouse movement: light acceleration.
    ;; Interval 8 ms (125 Hz). Min 3 px/tick -> Max 5 px/tick over 300 ms.
    ;; - Tap (single tick): 3 px = 375 px/s, fine for delicate positioning.
    ;; - Hold 300 ms+: 5 px/tick = 625 px/s (close to the 600 px/s target).
    ;; - Ramp duration 300 ms gives more time at the slow speed before
    ;;   ramping up; combined with the lower max this makes the movement
    ;;   feel lighter overall (was 4->8 over 200 ms, perceived as 1000 px/s).
    ;; Boost: ; position bound to (movemouse-speed 200) multiplies the
    ;; accel range by 2x while held: 6 -> 10 px/tick = 750 -> 1250 px/s.
    ;; Scroll: ; boost via switch with (input real ;) — movemouse-speed
    ;; doesn't affect mwheel, so a fork/select on (input real ;) selects
    ;; the dedicated fast aliases (240 vs 120 per 50ms).
    (defalias
      mmu      (movemouse-accel-up    8 300 3 5)
      mmd      (movemouse-accel-down  8 300 3 5)
      mml      (movemouse-accel-left  8 300 3 5)
      mmr      (movemouse-accel-right 8 300 3 5)
      mwu      (mwheel-up   50 120)
      mwd      (mwheel-down 50 120)
      mwu-fast (mwheel-up   50 240)
      mwd-fast (mwheel-down 50 240)
    )

    ;; Super+C: hold to activate mouse layer (no toggle).
    ;; fork with lmet as trigger so plain C still types c.
    ;; (layer-while-held mouse) activates mouse mode only while c is held;
    ;; release of c exits automatically.
    ;; (release-key lmet) synthetically releases Super to the OS on entry so
    ;;   Hyprland does not see Super held during mouse mode (avoids Super
    ;;   overlay / Super+key conflicts). kanata still tracks the physical
    ;;   lmet hold for the fork trigger; the layer-while-held is tied to the
    ;;   c key hold, so releasing the lmet output does not end the layer.
    ;;   Trade-off: Hyprland sees a brief Super down->up (phantom tap) on
    ;;   entry; same already happens on exit today. No delay on plain Super
    ;;   for normal Hyprland binds (unlike a defchordsv2 approach).
    ;; (cmd notify-send) fires the ON notification on activation.
    (defalias
      tog-c (fork c
                  (multi
                    (layer-while-held mouse)
                    (release-key lmet)
                    (cmd notify-send "Kanata: mouse ON" "h/j/k/l move  |  spc L-click  |  u R-click  |  y M-click  |  i scroll-up  |  o scroll-down  |  ; boost 2x  |  hold Super+C" -t 5000 -u normal))
                  (lmet)))

    ;; Default layer uses deflayermap (input->action pairs) instead of
    ;; positional deflayer columns. Only the c position is overridden;
    ;; all other keys implicitly use their defsrc value (the literal key).
    ;; c is bound to @tog-c so plain C still types c, but Super+C holds
    ;; the mouse layer (and masks Super via release-key) while both held.
    (deflayermap (default)
      c @tog-c
    )

    ;; Mouse layer: right-handable while Super+C is held (left hand).
    ;;   h j k l  - movement (right hand home row)
    ;;   spc      - mlft (hold to drag) -- left thumb
    ;;   u        - mrgt (right click)
    ;;   y        - mmid (middle click)
    ;;   i        - mwheel-up; ; held = 2x boost (right index)
    ;;   o        - mwheel-down; ; held = 2x boost (right ring)
    ;;   ;        - movemouse-speed 200 -- hjkl 2x boost (right pinky)
    ;;
    ;; Release of Super+C exits mouse mode automatically (layer-while-held).
    ;; x/esc removed; they were redundant exits with hold-based mode.
    ;;
    ;; i/o scroll boost uses (input real ;) via switch, because the ;
    ;; OUTPUT (movemouse-speed) isn't 'active' as a key output — fork's
    ;; (lsft-style) trigger check would miss it.
    (deflayermap (mouse)
      h    @mml
      j    @mmd
      k    @mmu
      l    @mmr
      spc  mlft
      u    mrgt
      y    mmid
      i    (switch
             ((input real ;)) @mwu-fast break
             ()                  @mwu     break)
      o    (switch
             ((input real ;)) @mwd-fast break
             ()                  @mwd     break)
      ;    (movemouse-speed 200)
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
        # XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS are inherited from the
        # user session so notify-send reaches the notification daemon.
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Ensure the kanata service restarts after every home-manager activation
    # so config changes from rebuilds always take effect. The reloadTriggers=
    # property on the service didn't wire up a path unit when tested, and
    # the systemd.user.paths schema is fiddly. entryAfter writeBoundary runs
    # this script after files (including the kbd symlink) have been written.
    # Cheap (a few seconds for kanata to start) and unambiguous.
    home.activation.kanataRestart = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -L "$HOME/.config/kanata/kanata.kbd" ]; then
        systemctl --user restart kanata.service 2>/dev/null || true
      fi
    '';
  };
}
