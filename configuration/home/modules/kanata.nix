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
    maxDist = "12";
  };

  kanataConfig = ''
    ;; hjkl mouse-emulation layer toggled by Super+C.
    ;;
    ;; Toggle chord: tap C while Super is held. Tapping C alone still types a c.
    ;; Toggling fires a desktop notification listing the active keybinds as a
    ;; reminder.
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
      movemouse-inherit-accel-state yes
      movemouse-smooth-diagonals yes
      linux-continue-if-no-devs-found yes
    )

    (defsrc
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
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

    ;; Toggle aliases: switch layer and post a desktop notification.
    ;; fork with lmet as the right-trigger means tog-c only fires when Super is
    ;; held while c is tapped; pressing c alone still types a c.
    (defalias
      mse-on (multi
        (layer-switch mouse)
        (cmd notify-send "Kanata: mouse layer ON" "h/j/k/l move  |  space L-click  |  f R-click  |  d M-click  |  u/i scroll  |  Super+C to exit" -t 2500 -u normal))
      mse-off (multi
        (layer-switch default)
        (cmd notify-send "Kanata: mouse layer OFF" -t 1500 -u low))
      tog-mse (switch
        ((base-layer mouse)) @mse-off break
        ()                  @mse-on  break)
      tog-c (fork c @tog-mse (lmet))
    )

    ;; Default layer: only c is remapped (to the Super+C toggle).
    (deflayer default
      grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
      caps a    s    d    f    g    h    j    k    l    ;    '    ret
      lsft z    x    @tog-c v    b    n    m    ,    .    /    rsft
      lctl lmet lalt           spc            ralt rmet rctl
    )

    ;; Mouse layer: hjkl = move, space/f/d = buttons, u/i = scroll.
    ;; lmet and c stay transparent so Super+C still toggles off; the other
    ;; modifiers (lctl, lalt, ralt, rmet, rctl) are transparent too so they
    ;; can compose with hjkl for Ctrl/Alt chords in the future.
    (deflayer mouse
      XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX
      XX   XX   XX   XX   XX   XX   XX   @mwu XX   @mwd XX   XX   XX   XX
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
