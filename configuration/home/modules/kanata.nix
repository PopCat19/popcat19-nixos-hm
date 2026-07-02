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

  # 8 ms tick, 600 ms to reach max speed, 1 px min, 12 px max per tick:
  # a quick tap nudges the cursor, holding flies across the screen.
  mouseAccel = {
    interval = "8";
    accelTime = "600";
    minDist = "1";
    maxDist = "8";
  };

  kanataConfig = ''
    ;; hjkl mouse-emulation layer.
    ;;
    ;; Entry: Super+C (chord). Tapping C alone still types a c.
    ;; Exit:  Super+Esc (chord). Fires from any layer; lands in default.
    ;;        Esc alone stays passthrough so vim/other apps keep working.
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
      mwu (mwheel-up   30 1)
      mwd (mwheel-down 30 1)
    )

    ;; Layer transitions: enter or exit mouse mode + post a notification.
    ;; Calling mse-on while already on mouse is a no-op (layer-switch to
    ;; current layer). Calling mse-off from default is also a no-op, so the
    ;; Super+Esc exit is safe to fire from anywhere.
    (defalias
      mse-on (multi
        (layer-switch mouse)
        (cmd notify-send "Kanata: mouse layer ON" "h/j/k/l move  |  space L-click  |  f R-click  |  d M-click  |  u/i scroll  |  Super+C enter  |  Super+Esc exit" -t 2500 -u normal))
      mse-off (multi
        (layer-switch default)
        (cmd notify-send "Kanata: mouse layer OFF" -t 1500 -u low))
      ;; Super+C: enter mouse mode. fork with lmet as trigger so plain C still
      ;; types a c.
      tog-c (fork c @mse-on (lmet))
      ;; Super+Esc: exit to default from any layer. fork with lmet as trigger
      ;; so plain Esc still emits Escape.
      esc-exit (fork esc @mse-off (lmet)))

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
    ;; esc directly exits to default (no fork: chord detection is unreliable
    ;; in kanata; users who need plain Esc for vim can tap once after exiting).
    ;; lmet/c/lctl/lalt/ralt/rmet/rctl are transparent so normal modifier
    ;; chords keep working and Super+C fork on the default layer still fires.
    (deflayer mouse
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   @mwu XX   @mwd XX   XX   XX   XX   (layer-switch default)
      XX   XX   XX   mmid mrgt XX   @mml @mmd @mmu @mmr XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
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
