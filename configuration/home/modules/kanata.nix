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
    ;; Mouse layer keys:
    ;;   h / j / k / l  - cursor movement (accelerates while held)
    ;;   spc            - left click (hold to drag)
    ;;   u              - right click
    ;;   s              - middle click
    ;;   i / o          - scroll up / down
    ;;   z              - 3x boost (movement); 2x for scroll when held at i/o press
    ;;   [ ]            - page up / page down
    ;;   , .            - home / end
    ;;   - =            - volume down / up
    ;;   0              - mute toggle
    ;;   7 8 9          - media prev / play-pause / next
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

    ;; Mouse movement: pronounced acceleration.
    ;; Interval 8 ms (125 Hz). Min 3 px/tick -> Max 10 px/tick over 300 ms.
    ;; - Tap (single tick): 3 px = 375 px/s, fine for delicate positioning.
    ;; - Hold 300 ms+: 10 px/tick = 1250 px/s for general movement.
    ;; The 3->10 range is intentionally wide so the accel is actually
    ;; perceptible; previous 3->5 (+2 px/tick over 300 ms) felt flat.
    ;; Boost: z position bound to (movemouse-speed 300) scales the accel
    ;; range 3x while held: 9 -> 30 px/tick over 300 ms (1125 -> 3750 px/s).
    ;; Higher multiplier = steeper slope on the same 300 ms ramp.
    ;; Scroll: z boost via switch with (input real z) — mwheel doesn't honor
    ;; movemouse-speed, so a switch on (input real z) selects the dedicated
    ;; fast aliases (240 vs 120 per 50 ms = exactly 2x).
    ;; Scroll boost timing: the (input real z) check fires once at i/o press
    ;; time. z must be held WHEN i/o is pressed for fast scroll. Pressing z
    ;; mid-scroll does not re-evaluate the switch — kanata binds the resolved
    ;; alias for the duration of the hold. Mid-scroll dynamic boost would
    ;; require a layer-switch on z, which conflicts with this layer's use of
    ;; z for movemouse-speed.
    (defalias
      mmu      (movemouse-accel-up    8 300 3 10)
      mmd      (movemouse-accel-down  8 300 3 10)
      mml      (movemouse-accel-left  8 300 3 10)
      mmr      (movemouse-accel-right 8 300 3 10)
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
                    (cmd notify-send "Kanata: mouse ON" "h/j/k/l move  |  spc L-click  |  u R-click  |  s M-click  |  i scroll-up  |  o scroll-down  |  z boost 3x (move) / 2x (scroll)  |  [ ] pgup/pgdn  |  , . home/end  |  - = vol dn/up  |  0 mute  |  7 8 9 media prev/play/next  |  hold Super+C" -t 5000 -u normal))
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
    ;;   s        - mmid (middle click)
    ;;   i        - mwheel-up; z held = 2x boost (right index)
    ;;   o        - mwheel-down; z held = 2x boost (right ring)
    ;;   z        - movemouse-speed 200 -- hjkl 2x boost (left pinky, below a)
    ;;   [ ]      - pgup / pgdn (right index, top row)
    ;;   , .      - home / end (right ring, bottom row)
    ;;   - =      - volume down / up (right index, top row)
    ;;   0        - mute toggle (right pinky, top row)
    ;;   7 8 9    - media prev / play-pause / next (right pinky/ring, top row)
    ;;
    ;; Release of Super+C exits mouse mode automatically (layer-while-held).
    ;; x/esc removed; they were redundant exits with hold-based mode.
    ;;
    ;; i/o scroll boost uses (input real z) via switch, because the z
    ;; OUTPUT (movemouse-speed) isn't 'active' as a key output — fork's
    ;; (lsft-style) trigger check would miss it.
    ;;
    ;; ___ XX: wildcard mapping every unmapped key to no-op. Nothing
    ;; else leaks to Hyprland during mouse mode (prevents phantom
    ;; Super+key or plain-key multi-actions). The explicitly mapped keys
    ;; above still work. Already-held keys (c, lmet) are unaffected —
    ;; layer change does not re-trigger held keys, and their release is
    ;; driven by the press-time action (layer-while-held / lmet output).
    ;; Force-exit (lctl+spc+esc) still works: it is handled before any
    ;; layer/kanata remapping.
    (deflayermap (mouse)
      h    @mml
      j    @mmd
      k    @mmu
      l    @mmr
      spc  mlft
      u    mrgt
      s    mmid
      i    (switch
             ((input real z)) @mwu-fast break
             ()                  @mwu     break)
      o    (switch
             ((input real z)) @mwd-fast break
             ()                  @mwd     break)
      z    (movemouse-speed 300)
      [    pgup
      ]    pgdn
      ,    home
      .    end
      -    vold
      =    volu
      0    mute
      7    prev
      8    pp
      9    next
      ___  XX
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
    #
    # When invoked via sudo nixos-rebuild switch (or nh os switch), the
    # home-manager activation runs as the user but the user systemd session
    # may not be reachable from this context (no $XDG_RUNTIME_DIR or the
    # bus socket isn't mounted). Detect that case and skip the restart
    # rather than failing the whole activation. A failure to restart is
    # logged but never fatal — the service will pick up the new kbd symlink
    # on its next start.
    home.activation.kanataRestart = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -L "$HOME/.config/kanata/kanata.kbd" ]; then
        if [ -n "$XDG_RUNTIME_DIR" ] && systemctl --user status >/dev/null 2>&1; then
          echo "kanata: restarting user service..."
          systemctl --user try-restart kanata.service \
            || echo "kanata: restart failed (will pick up on next start)"
          echo "kanata: restart complete"
        else
          echo "kanata: user systemd session not reachable; skipping restart"
        fi
      fi
    '';
  };
}
