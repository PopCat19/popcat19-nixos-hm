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

  # 8 ms tick, 400 ms to reach max speed, 1 px min, 10 px max per tick:
  # a quick tap nudges the cursor, holding reaches cruise speed fast.
  mouseAccel = {
    interval = "8";
    accelTime = "400";
    minDist = "1";
    maxDist = "10";
  };

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

    ;; Mouse movement with acceleration: <interval_ms> <accel_time_ms> <min_px> <max_px>
    (defalias
      mmu (movemouse-accel-up    ${mouseAccel.interval} ${mouseAccel.accelTime} ${mouseAccel.minDist} ${mouseAccel.maxDist})
      mmd (movemouse-accel-down  ${mouseAccel.interval} ${mouseAccel.accelTime} ${mouseAccel.minDist} ${mouseAccel.maxDist})
      mml (movemouse-accel-left  ${mouseAccel.interval} ${mouseAccel.accelTime} ${mouseAccel.minDist} ${mouseAccel.maxDist})
      mmr (movemouse-accel-right ${mouseAccel.interval} ${mouseAccel.accelTime} ${mouseAccel.minDist} ${mouseAccel.maxDist})
      mwu (mwheel-up   50 120)
      mwd (mwheel-down 50 120)
    )

    ;; Layer transitions: enter or exit mouse mode + post a notification.
    ;; Calling mse-on while already on mouse is a no-op (layer-switch to
    ;; current layer). Calling mse-off from default is also a no-op, so the
    ;; plain-Esc exit on the mouse layer is safe to fire from anywhere.
    (defalias
      mse-on (multi
        (layer-switch mouse)
        (cmd notify-send "Kanata: mouse ON" "h/j/k/l move  |  spc L-click  |  f R-click  |  g M-click  |  u scroll-up  |  d scroll-down  |  Super+C enter  |  x or Esc exit  |  z pause 5s" -t 5000 -u normal))
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

    ;; Virtual key: re-enter mouse layer. Used by z's pause sequence.
    (defvirtualkeys
      vk-mouse-on (layer-switch mouse)
    )

    ;; z: pause mouse emulation for 5s, then re-enter. Exits to default
    ;; immediately (direct layer-switch, not in multi, to avoid the
    ;; multi+layer-switch ordering bug). Schedules re-entry via
    ;; on-physical-idle, which fires after 5000ms of physical-key idle.
    ;; Note: on-physical-idle resets if any physical key is pressed during
    ;; the pause, so the actual wall-clock time before re-entry can exceed
    ;; 5s if you're typing hjkl/etc during the pause.
    ;; on-physical-idle parses tap-vkey as its inner argument, so we
    ;; don't need a multi wrapper.
    (defalias
      z (multi
        (layer-switch default)
        (on-physical-idle 5000 tap-vkey vk-mouse-on)))

    ;; Default layer: c and esc are remapped (to the Super+ chords).
    ;; lmet position stays as the literal lmet action so the forks detect it.
    (deflayer default
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \    esc
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft z    x    @tog-c v    b    n    m    ,    .    /    rsft
      lctl lmet lalt           spc            ralt rmet rctl
    )

    ;; Mouse layer: hjkl = move, space/f/d = buttons, u/i = scroll.
    ;; x and esc exit to default via direct (layer-switch default). Both
    ;; bypass mse-off (multi with notify-send) because:
    ;;   - multi has documented ordering bugs that swallow the layer switch
    ;;     when (layer-switch) is paired with (cmd notify-send)
    ;;   - on layer-switch, the key release is processed on the new layer,
    ;;     which would leak an Escape to the focused app otherwise
    ;; Trade-off: no OFF notification on exit. Entry ON notification still fires.
    ;; z pauses mouse emulation for 3s (macro + virtual keys), then re-enters.
    ;; lmet/lctl/lalt/ralt/rmet/rctl are transparent so normal modifier
    ;; chords keep working and Super+C fork on the default layer still fires.
    (deflayer mouse
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   @mwu _    _    XX   XX   XX   XX   (layer-switch default)
      XX   XX   XX   @mwd mrgt mmid @mml @mmd @mmu @mmr XX   XX   XX
      XX   @z     (layer-switch default) XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   _    _              mlft            _    _    _
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
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR1 $MAINPID";
        Restart = "on-failure";
        RestartSec = "5s";
        # XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS are inherited from the
        # user session so notify-send reaches the notification daemon.
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
