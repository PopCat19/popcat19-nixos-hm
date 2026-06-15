# alpine-klipper-builder.nix
#
# Purpose: Build a reproducible Alpine diskless apkovl for the Klipper Pi 4B
#
# This module:
# - Fetches the Alpine Linux RPi aarch64 release tarball
# - Assembles an apkovl.tar.gz that preconfigures:
#   - Packages: fish, starship, syncthing, NetworkManager, Caddy, git, python3
#   - WiFi client + AP fallback profiles
#   - SSH authorized keys from the build host
#   - Syncthing folder/devices (mirrors NixOS config)
#   - Starship prompt (mirrors starship.nix)
#   - First-boot setup: clones klipper/moonraker, downloads mainsail, starts services
#   - In-place update script: git pull + pip install + restart
#   - Persistent /home on SD ext4 partition
#
# Output: headless.apkovl.tar.gz — place on boot partition of SD card
{
  stdenv,
  lib,
  writeText,
  writeTextFile,
  writeShellScript,
  runCommand,
  fetchurl,
  gnused,
  gnutar,
  gzip,
  dosfstools,
  mtools,
  e2fsprogs,
  parted,
  util-linux,
}:
let

  alpineVersion = "3.24.0";
  alpineBranch = "v3.24";
  alpineTarball = fetchurl {
    url = "https://dl-cdn.alpinelinux.org/alpine/${alpineBranch}/releases/aarch64/alpine-rpi-${alpineVersion}-aarch64.tar.gz";
    hash = "sha256-zInYxQTj2781KBgPBQKy8SUwZLNd7djKjvJ/nJdUFXY=";
  };


  syncthingDevices = {
    nixos0 = "K6FLBMQ-5CJEX4X-VL4KETN-7AYJQW5-5VTXJWY-CLRMKBV-TGXIU26-WUY74QZ";
    s23u = "QP7SCT2-7XQTOK3-WTTSZ5T-T6BH4EZ-IA7VEIQ-RUQO5UV-FWWRF5L-LDQXTAS";
    surface0 = "5HCOSXJ-N56FEEI-VIUQRUV-S2LCQTM-AZK4DSC-5AOSNYF-7RQTTZM-6VOJYAN";
    thinkpad0 = "77NUF7I-XOXG3XA-LZDKCTC-ORPOQYO-4YBTFUW-RKIHOOZ-UYP7VOP-RBRUWQV";
    klipper = "QMYQRZC-LHTMXBZ-EDCPAYX-OZX2BFJ-BHOQ32K-DL4QDM4-VJF2CJ2-PDH3WQK";
  };
in
{
  username ? "popcat19",
  hostname ? "popcat19-klipper0",
  wifiSsid ? "Beave_Net_IoT",
  wifiPsk ? "",
  sshAuthorizedKeys ? [ ],
  klipperDataDir ? "/home/${username}/printer_data",
}:
let
  inherit (lib) concatStringsSep escapeShellArg;


  apkWorld = concatStringsSep "\n" [
    "fish"
    "starship"
    "starship-fish"
    "syncthing"
    "networkmanager"
    "networkmanager-wifi"
    "caddy"
    "git"
    "python3"
    "py3-pip"
    "py3-virtualenv"
    "jq"
    "udev"
    "curl"
    "unzip"
    "build-base"
    "python3-dev"
    "libffi-dev"
    "wpa_supplicant"
    "hostapd"
    "vim"
    "eza"
    "micro"
    "wget"
    "htop"
    "tmux"
    "coreutils"
    "procps"
    "ncurses-dev"
    "libsodium"
    "curl-dev"
    "freetype-dev"
    "fribidi-dev"
    "harfbuzz-dev"
    "jpeg-dev"
    "lcms2-dev"
    "openjpeg-dev"
    "tcl-dev"
    "tiff-dev"
    "tk-dev"
    "zlib-dev"
  ];


  authorizedKeysFile = writeText "authorized_keys" (concatStringsSep "\n" sshAuthorizedKeys);


  fishConfig = writeText "config.fish" ''
    set -gx EDITOR micro
    set -gx VISUAL micro

    if status is-interactive
        starship init fish | source
        alias ll 'eza -la --icons --group-directories-first'
        alias lt 'eza -la --icons --group-directories-first --tree --level=2'
        alias .. 'cd ..'
        alias ... 'cd ../..'

        alias kupdate 'update-klipper'

        alias sysupdate 'sudo apk update && sudo apk upgrade && sudo lbu commit'

        alias ap-on 'sudo nmcli connection down ${escapeShellArg wifiSsid} 2>/dev/null; sudo nmcli connection up Klipper-Setup'
        alias ap-off 'sudo nmcli connection down Klipper-Setup 2>/dev/null; sudo nmcli connection up ${escapeShellArg wifiSsid}'
    end

    function fish_greeting
        echo (set_color cyan)"  Alpine Diskless Klipper Pi — $hostname"(set_color normal)
        echo ""
    end
  '';


  starshipConfig = writeText "starship.toml" ''
    format = "$time$directory$git_branch$git_status$line_break$character"

    [character]
    error_symbol = "[❯](bold red)"
    success_symbol = "[❯](bold green)"
    vimcmd_symbol = "[❮](bold purple)"

    [cmd_duration]
    format = "[$duration]($style) "
    min_time = 2000
    style = "bold yellow"

    [directory]
    format = "[$path]($style)[$read_only]($read_only_style) "
    read_only = " 󰌾"
    read_only_style = "red"
    style = "bold purple"
    truncate_to_repo = false
    truncation_length = 3

    [git_branch]
    format = "[$symbol$branch(:$remote_branch)]($style) "
    only_attached = true
    style = "bold green"
    symbol = " "

    [git_status]
    ahead = "⇡''${count}"
    behind = "⇣''${count}"
    conflicted = "="
    deleted = "✘''${count}"
    diverged = "⇕⇡''${ahead_count}⇣''${behind_count}"
    format = "([\\[$all_status$ahead_behind\\]]($style) )"
    modified = "!''${count}"
    renamed = "»''${count}"
    staged = "+''${count}"
    stashed = "≡''${count}"
    style = "bold red"
    untracked = "?''${count}"
    up_to_date = ""

    [hostname]
    format = "[$hostname]($style) in "
    ssh_only = true
    style = "bold green"

    [time]
    disabled = false
    format = "[$time]($style) "
    style = "bold black"
    time_format = "%T"
    utc_time_offset = "local"

    [username]
    format = "[$user]($style)@"
    show_always = false
    style_root = "bold red"
    style_user = "bold white"
  '';


  syncthingConfig = writeText "config.xml" ''
    <configuration version="39">
        <folder id="keepass-vault" label="KeePass Vault" path="/home/${username}/Passwords" type="sendreceive" rescanIntervalS="60" ignorePerms="true">
            <device id="${syncthingDevices.nixos0}" name="nixos0"/>
            <device id="${syncthingDevices.s23u}" name="s23u"/>
            <device id="${syncthingDevices.surface0}" name="surface0"/>
            <device id="${syncthingDevices.thinkpad0}" name="thinkpad0"/>
            <device id="${syncthingDevices.klipper}" name="klipper"/>
        </folder>
        <folder id="syncthing-shared" label="Syncthing Shared" path="/home/${username}/SyncthingShared" type="sendreceive" rescanIntervalS="300" ignorePerms="true">
            <device id="${syncthingDevices.nixos0}" name="nixos0"/>
            <device id="${syncthingDevices.s23u}" name="s23u"/>
            <device id="${syncthingDevices.surface0}" name="surface0"/>
            <device id="${syncthingDevices.thinkpad0}" name="thinkpad0"/>
            <device id="${syncthingDevices.klipper}" name="klipper"/>
        </folder>
        <folder id="pi-klipper" label="Pi Klipper" path="/home/${username}/SyncthingShared/pi-klipper" type="sendreceive" rescanIntervalS="30" ignorePerms="true">
            <device id="${syncthingDevices.nixos0}" name="nixos0"/>
            <device id="${syncthingDevices.klipper}" name="klipper"/>
        </folder>
        <device id="${syncthingDevices.nixos0}" name="nixos0">
            <address>dynamic</address>
        </device>
        <device id="${syncthingDevices.s23u}" name="s23u">
            <address>dynamic</address>
        </device>
        <device id="${syncthingDevices.surface0}" name="surface0">
            <address>dynamic</address>
        </device>
        <device id="${syncthingDevices.thinkpad0}" name="thinkpad0">
            <address>dynamic</address>
        </device>
        <device id="${syncthingDevices.klipper}" name="klipper">
            <address>dynamic</address>
        </device>
        <options>
            <globalAnnounceEnabled>true</globalAnnounceEnabled>
            <localAnnounceEnabled>true</localAnnounceEnabled>
            <relaysEnabled>true</relaysEnabled>
        </options>
        <gui enabled="false"/>
    </configuration>
  '';


  wifiProfile = writeText "${wifiSsid}.nmconnection" ''
    [connection]
    id=${wifiSsid}
    uuid=0278899c-f325-4669-ad07-06abc09f893d
    type=wifi
    interface-name=wlan0
    autoconnect=true
    autoconnect-priority=100

    [wifi]
    mode=infrastructure
    ssid=${wifiSsid}

    [wifi-security]
    auth-alg=open
    key-mgmt=wpa-psk
    psk=${wifiPsk}

    [ipv4]
    method=auto

    [ipv6]
    addr-gen-mode=default
    method=auto
  '';


  apProfile = writeText "Klipper-Setup.nmconnection" ''
    [connection]
    id=Klipper-Setup
    uuid=9c7a3e6b-8f2d-4e1a-9d5c-2b4f6a8c0e12
    type=wifi
    interface-name=wlan0
    autoconnect=false

    [wifi]
    mode=ap
    band=bg
    channel=6
    ssid=Klipper-Setup

    [wifi-security]
    auth-alg=open
    key-mgmt=wpa-psk
    psk=klipper-setup

    [ipv4]
    method=manual
    addresses=192.168.50.1/24

    [ipv6]
    method=disabled
  '';


  apFallbackDispatcher = writeShellScript "90-klipper-ap-fallback" ''
    # NetworkManager dispatcher: auto-bring-up AP when client WiFi is unavailable
    IFACE="$1"
    ACTION="$2"

    [ "''${IFACE}" = "wlan0" ] || exit 0

    CLIENT="${wifiSsid}"
    AP="Klipper-Setup"

    if [ "$ACTION" = "down" ]; then
      nmcli connection show --active | grep -q "$CLIENT" && exit 0
      # Client WiFi went down and isn't coming back — bring up AP
      nmcli connection up "$AP" 2>/dev/null || true
    elif [ "$ACTION" = "up" ]; then
      # Client WiFi is back — stop AP if it's up
      if nmcli connection show --active | grep -q "$AP"; then
        nmcli connection down "$AP" 2>/dev/null || true
      fi
    fi
  '';


  caddyConfig = writeText "Caddyfile" ''
    :80

    encode gzip

    root * /home/${username}/www

    @moonraker {
      path /server/* /websocket /printer/* /access/* /api/* /machine/*
    }

    route @moonraker {
      reverse_proxy localhost:7125
    }

    route /webcam {
      reverse_proxy localhost:8081
    }

    route {
      try_files {path} {path}/ /index.html
      file_server
    }
  '';


  sshdConfig = writeText "sshd_config" ''
    Port 22
    PasswordAuthentication yes
    PermitRootLogin yes
    PubkeyAuthentication yes
    AuthorizedKeysFile .ssh/authorized_keys
    UseDNS no
    Subsystem sftp internal-sftp
  '';


  fstab = writeText "fstab" ''
    LABEL=ALPINE_DATA  /home  ext4  defaults,noatime  0  2
  '';


  firstBootSetup = writeShellScript "first-boot-setup" ''
    set -euo pipefail

    MARKER="/home/${username}/.klipper-setup-done"
    [ -f "$MARKER" ] && exit 0

    echo "=== Alpine Klipper first-boot setup ==="

    HOME_DIR="/home/${username}"
    USER="${username}"

    # The apkovl fstab mounts LABEL=ALPINE_DATA to /home.
    # Wait up to 30s for the mount to appear (first boot: partition may need fsck).
    for i in $(seq 1 30); do
      if mountpoint -q /home && [ -d "$HOME_DIR" ]; then
        break
      fi
      echo "Waiting for persistent /home... ($i/30)"
      sleep 1
    done

    if ! mountpoint -q /home; then
      echo "ERROR: /home not mounted. Check SD card partition label (ALPINE_DATA)." >&2
      exit 1
    fi

    mkdir -p "$HOME_DIR"/.ssh
    chmod 700 "$HOME_DIR"/.ssh
    cp /etc/ssh/authorized_keys "$HOME_DIR"/.ssh/authorized_keys 2>/dev/null || true
    chmod 600 "$HOME_DIR"/.ssh/authorized_keys
    chown -R "$USER:$USER" "$HOME_DIR"/.ssh

    mkdir -p "$HOME_DIR"/Passwords
    mkdir -p "$HOME_DIR"/SyncthingShared/pi-klipper
    mkdir -p "$HOME_DIR"/www

    chown -R "$USER:$USER" "$HOME_DIR"

    echo "Installing klipper..."
    KLIPPER_PATH="$HOME_DIR/klipper"
    KLIPPY_VENV="$HOME_DIR/venv/klippy"

    if [ ! -d "$KLIPPER_PATH" ]; then
      git clone https://github.com/Klipper3d/klipper.git "$KLIPPER_PATH"
      chown -R "$USER:$USER" "$KLIPPER_PATH"
    fi

    mkdir -p "$(dirname "$KLIPPY_VENV")"
    if [ ! -d "$KLIPPY_VENV" ]; then
      su -s /bin/sh "$USER" -c "python3 -m venv '$KLIPPY_VENV'"
      su -s /bin/sh "$USER" -c "'$KLIPPY_VENV/bin/pip' install --upgrade pip"
      su -s /bin/sh "$USER" -c "'$KLIPPY_VENV/bin/pip' install -r '$KLIPPER_PATH/scripts/klippy-requirements.txt'"
    fi

    echo "Installing moonraker..."
    MOONRAKER_PATH="$HOME_DIR/moonraker"
    MOONRAKER_VENV="$HOME_DIR/venv/moonraker"

    if [ ! -d "$MOONRAKER_PATH" ]; then
      git clone https://github.com/Arksine/moonraker.git "$MOONRAKER_PATH"
      chown -R "$USER:$USER" "$MOONRAKER_PATH"
    fi

    mkdir -p "$(dirname "$MOONRAKER_VENV")"
    if [ ! -d "$MOONRAKER_VENV" ]; then
      su -s /bin/sh "$USER" -c "python3 -m venv '$MOONRAKER_VENV'"
      su -s /bin/sh "$USER" -c "'$MOONRAKER_VENV/bin/pip' install --upgrade pip"
      su -s /bin/sh "$USER" -c "'$MOONRAKER_VENV/bin/pip' install -r '$MOONRAKER_PATH/scripts/moonraker-requirements.txt'"
    fi

    echo "Downloading mainsail..."
    MAINDIR="$HOME_DIR/www"
    MAIN_RELEASE=$(curl -s https://api.github.com/repos/mainsail-crew/mainsail/releases | jq -r '.[0].assets[0].browser_download_url')
    if [ -n "$MAIN_RELEASE" ] && [ "$MAIN_RELEASE" != "null" ]; then
      curl -sLo "$MAINDIR/mainsail.zip" "$MAIN_RELEASE"
      unzip -o "$MAINDIR/mainsail.zip" -d "$MAINDIR"
      rm "$MAINDIR/mainsail.zip"
      chown -R "$USER:$USER" "$MAINDIR"
    else
      echo "WARNING: Could not fetch mainsail release URL"
    fi

    PRINTER_CFG="$HOME_DIR/SyncthingShared/pi-klipper/printer_data/config/printer.cfg"
    if [ ! -f "$PRINTER_CFG" ]; then
      mkdir -p "$(dirname "$PRINTER_CFG")"
      cat > "$PRINTER_CFG" << 'PRINTER_CFG_EOF'
    # Klipper printer.cfg — seeded by alpine-klipper-apkovl
    #
    # Full config is in ~/SyncthingShared/pi-klipper/printer.cfg on nixos0.
    # Copy it here or configure via Mainsail UI at http://klipper.local

    [mcu]
    serial: /dev/serial/by-id/usb-Klipper_stm32g0b1xx*

    [virtual_sdcard]
    path: /home/popcat19/printer_data/gcodes
    on_error_gcode: CANCEL_PRINT

    [printer]
    kinematics: cartesian
    max_velocity: 300
    max_accel: 3000
    max_z_velocity: 15
    max_z_accel: 100
    PRINTER_CFG_EOF
      chown "$USER:$USER" "$PRINTER_CFG"
    fi

    MOONRAKER_CFG="$HOME_DIR/printer_data/config/moonraker.conf"
    if [ ! -f "$MOONRAKER_CFG" ]; then
      mkdir -p "$(dirname "$MOONRAKER_CFG")"
      cat > "$MOONRAKER_CFG" << MOONRAKER_EOF
    [server]
    host: 0.0.0.0
    port: 7125
    klippy_uds_address: /tmp/klippy_uds

    [file_manager]
    config_path: $HOME_DIR/printer_data/config
    log_path: $HOME_DIR/printer_data/logs

    [authorization]
    trusted_clients:
      127.0.0.0/8
      192.168.0.0/16
      10.0.0.0/8
      169.254.0.0/16
      172.16.0.0/12
      FC00::/7
      FE80::/10
      ::1/128

    cors_domains:
      *.lan
      *.local
      *://localhost
      *://localhost:*

    [octoprint_compat]

    [history]
    MOONRAKER_EOF
      chown "$USER:$USER" "$MOONRAKER_CFG"
    fi

    mkdir -p "$HOME_DIR"/printer_data/{config,logs,gcodes,database}
    chown -R "$USER:$USER" "$HOME_DIR"/printer_data

    SYNCTHING_CFG="$HOME_DIR/SyncthingShared/pi-klipper/printer_data/config/printer.cfg"
    MOONRAKER_PRINTER_CFG="$HOME_DIR/printer_data/config/printer.cfg"
    if [ -f "$SYNCTHING_CFG" ]; then
      ln -sf "$SYNCTHING_CFG" "$MOONRAKER_PRINTER_CFG"
    fi
    chown -h "$USER:$USER" "$MOONRAKER_PRINTER_CFG" 2>/dev/null || true


    # Klipper init script
    cat > /etc/init.d/klipper << OPENRC_KLIPPER
    #!/sbin/openrc-run
    name=klipper
    description="Klipper 3D printer firmware"
    command="$KLIPPY_VENV/bin/python"
    command_args="$KLIPPER_PATH/klippy/klippy.py $MOONRAKER_PRINTER_CFG -l $HOME_DIR/printer_data/logs/klippy.log -a /tmp/klippy_uds"
    command_background=true
    command_user="$USER"
    pidfile="/run/klipper.pid"
    depend() {
      need net
      after moonraker
    }
    OPENRC_KLIPPER
    chmod +x /etc/init.d/klipper

    # Moonraker init script
    cat > /etc/init.d/moonraker << OPENRC_MOONRAKER
    #!/sbin/openrc-run
    name=moonraker
    description="Moonraker API server for Klipper"
    command="$MOONRAKER_VENV/bin/python"
    command_args="$MOONRAKER_PATH/moonraker/moonraker.py -d $HOME_DIR/printer_data"
    command_background=true
    command_user="$USER"
    pidfile="/run/moonraker.pid"
    depend() {
      need net
    }
    OPENRC_MOONRAKER
    chmod +x /etc/init.d/moonraker

    # Syncthing init script
    cat > /etc/init.d/syncthing << OPENRC_SYNCTHING
    #!/sbin/openrc-run
    name=syncthing
    description="Syncthing file synchronization"
    command="/usr/bin/syncthing"
    command_args="-no-browser -home=$HOME_DIR/.config/syncthing"
    command_background=true
    command_user="$USER"
    pidfile="/run/syncthing.pid"
    depend() {
      need net localmount
    }
    OPENRC_SYNCTHING
    chmod +x /etc/init.d/syncthing
    mkdir -p "$HOME_DIR/.config/syncthing"
    cp /home/${username}/.config/syncthing/config.xml "$HOME_DIR/.config/syncthing/config.xml" 2>/dev/null || true
    chown -R "$USER:$USER" "$HOME_DIR/.config/syncthing"

    # Caddy init script
    cat > /etc/init.d/caddy << OPENRC_CADDY
    #!/sbin/openrc-run
    name=caddy
    description="Caddy web server"
    command="/usr/sbin/caddy"
    command_args="run --config /etc/caddy/Caddyfile"
    command_background=true
    command_user="root"
    pidfile="/run/caddy.pid"
    depend() {
      need net
    }
    OPENRC_CADDY
    chmod +x /etc/init.d/caddy

    rc-update add networkmanager default
    rc-update add syncthing default
    rc-update add caddy default
    rc-update add moonraker default
    rc-update add klipper default

    rc-service networkmanager start
    rc-service syncthing start
    rc-service caddy start
    rc-service moonraker start
    rc-service klipper start

    date > "$MARKER"
    echo "=== First-boot setup complete ==="
  '';


  updateScript = writeShellScript "update-klipper" ''
    set -euo pipefail

    HOME_DIR="/home/${username}"

    echo "=== Updating Klipper stack ==="

    echo "[klipper] git pull + pip install..."
    sudo rc-service klipper stop 2>/dev/null || true
    cd "$HOME_DIR/klipper"
    git fetch origin
    git reset --hard origin/master
    "$HOME_DIR/venv/klippy/bin/pip" install -r "$HOME_DIR/klipper/scripts/klippy-requirements.txt"
    sudo rc-service klipper start

    echo "[moonraker] git pull + pip install..."
    sudo rc-service moonraker stop 2>/dev/null || true
    cd "$HOME_DIR/moonraker"
    git fetch origin
    git reset --hard origin/master
    "$HOME_DIR/venv/moonraker/bin/pip" install -r "$HOME_DIR/moonraker/scripts/moonraker-requirements.txt"
    sudo rc-service moonraker start

    echo "[mainsail] download latest release..."
    cd "$HOME_DIR/www"
    MAIN_RELEASE=$(curl -s https://api.github.com/repos/mainsail-crew/mainsail/releases | jq -r '.[0].assets[0].browser_download_url')
    if [ -n "$MAIN_RELEASE" ] && [ "$MAIN_RELEASE" != "null" ]; then
      curl -sLo /tmp/mainsail.zip "$MAIN_RELEASE"
      rm -rf "$HOME_DIR/www"/*
      unzip -o /tmp/mainsail.zip -d "$HOME_DIR/www"
      rm /tmp/mainsail.zip
      chown -R ${username}:${username} "$HOME_DIR/www"
    else
      echo "WARNING: Could not fetch mainsail release URL"
    fi

    sudo rc-service caddy restart 2>/dev/null || true

    echo "=== Update complete ==="
  '';


  apkovl = runCommand "headless.apkovl.tar.gz"
    {
      nativeBuildInputs = [ gnutar gzip ];
      meta.description = "Alpine diskless apkovl for Klipper Pi 4B";
    }
    ''
      mkdir -p rootfs/etc/{apk,NetworkManager/system-connections,NetworkManager/dispatcher.d,ssh,local.d,init.d,caddy}
      mkdir -p rootfs/home/${username}/.config/{fish,syncthing}
      mkdir -p rootfs/home/${username}/.ssh
      mkdir -p rootfs/usr/local/bin

      cp ${writeText "world" apkWorld} rootfs/etc/apk/world

      cp ${sshdConfig} rootfs/etc/ssh/sshd_config
      cp ${authorizedKeysFile} rootfs/etc/ssh/authorized_keys
      cp ${authorizedKeysFile} rootfs/home/${username}/.ssh/authorized_keys

      cp ${fishConfig} rootfs/home/${username}/.config/fish/config.fish

      cp ${starshipConfig} rootfs/home/${username}/.config/starship.toml

      cp ${syncthingConfig} rootfs/home/${username}/.config/syncthing/config.xml

      cp ${wifiProfile} "rootfs/etc/NetworkManager/system-connections/${wifiSsid}.nmconnection"
      chmod 600 "rootfs/etc/NetworkManager/system-connections/${wifiSsid}.nmconnection"
      cp ${apProfile} rootfs/etc/NetworkManager/system-connections/Klipper-Setup.nmconnection
      chmod 600 rootfs/etc/NetworkManager/system-connections/Klipper-Setup.nmconnection

      cp ${apFallbackDispatcher} rootfs/etc/NetworkManager/dispatcher.d/90-klipper-ap-fallback
      chmod +x rootfs/etc/NetworkManager/dispatcher.d/90-klipper-ap-fallback

      cp ${caddyConfig} rootfs/etc/caddy/Caddyfile

      cp ${fstab} rootfs/etc/fstab

      cp ${firstBootSetup} rootfs/etc/local.d/first-boot.start
      chmod +x rootfs/etc/local.d/first-boot.start

      cp ${updateScript} rootfs/usr/local/bin/update-klipper
      chmod +x rootfs/usr/local/bin/update-klipper

      cd rootfs
      tar czf "$out" .
    '';


  bootPartitionDir = runCommand "klipper-alpine-boot"
    {
      nativeBuildInputs = [ gnutar ];
      meta.description = "Complete Alpine boot partition for Klipper Pi 4B SD card";
    }
    ''
      mkdir -p "$out"
      tar xf ${alpineTarball} -C "$out"

      cp ${apkovl} "$out/headless.apkovl.tar.gz"

      ${gnused}/bin/sed -i 's/modules=loop,squashfs,sd-mod,usb-storage quiet/modules=loop,squashfs,sd-mod,usb-storage console=tty1/' "$out/cmdline.txt" 2>/dev/null || true

      echo "Alpine Klipper boot partition ready at $out"
      echo "Flash to SD card FAT32 partition (label: ALPINE_BOOT)."
      echo "Create ext4 partition (label: ALPINE_DATA) for persistent /home."
    '';


  deployScript = writeShellScript "deploy-klipper-alpine" ''
    set -euo pipefail

    SDCARD="''${1:-}"
    if [ -z "$SDCARD" ]; then
      echo "Usage: deploy-klipper-alpine /dev/mmcblkX" >&2
      echo "" >&2
      echo "This script partitions and flashes an SD card with Alpine diskless Klipper." >&2
      echo "" >&2
      echo "WARNING: This will DESTROY all data on $SDCARD." >&2
      exit 1
    fi

    if [ ! -b "$SDCARD" ]; then
      echo "ERROR: $SDCARD is not a block device" >&2
      exit 1
    fi

    echo "=== Alpine Klipper Pi SD card deployment ==="
    echo "Target: $SDCARD"
    echo ""
    echo "WARNING: This will DESTROY all data on $SDCARD!"
    read -p "Type YES to continue: " confirm
    [ "$confirm" = "YES" ] || exit 0

    echo "Partitioning..."
    sudo parted -s "$SDCARD" mklabel msdos
    sudo parted -s "$SDCARD" mkpart primary fat32 1MiB 257MiB
    sudo parted -s "$SDCARD" mkpart primary ext4 257MiB 100%
    sudo parted -s "$SDCARD" set 1 boot on

    BOOT="''${SDCARD}p1"
    DATA="''${SDCARD}p2"
    [ -b "$BOOT" ] || BOOT="''${SDCARD}1"
    [ -b "$DATA" ] || DATA="''${SDCARD}2"

    echo "Formatting..."
    sudo mkfs.vfat -n ALPINE_BOOT "$BOOT"
    sudo mkfs.ext4 -F -L ALPINE_DATA "$DATA"

    BOOT_MNT=$(mktemp -d)
    sudo mount "$BOOT" "$BOOT_MNT"

    echo "Copying boot files..."
    sudo cp -r ${bootPartitionDir}/* "$BOOT_MNT"/

    sudo umount "$BOOT_MNT"
    rmdir "$BOOT_MNT"

    echo ""
    echo "=== Done ==="
    echo "Insert SD card into Raspberry Pi 4B and power on."
    echo "First boot will install klipper/moonraker/mainsail (~5 min)."
    echo "SSH: ssh ${username}@${hostname}.local"
  '';

  diskImage = runCommand "klipper-alpine.img"
    {
      nativeBuildInputs = [
        gnutar
        dosfstools
        mtools
        e2fsprogs
        parted
        util-linux
      ];
      meta.description = "Complete dd-able SD card image — Alpine diskless Klipper Pi 4B";
    }
    ''

      BOOT_CONTENT="$PWD/boot-files"
      mkdir -p "$BOOT_CONTENT"
      tar xf ${alpineTarball} -C "$BOOT_CONTENT"
      cp ${apkovl} "$BOOT_CONTENT/headless.apkovl.tar.gz"
      ${gnused}/bin/sed -i \
        's/modules=loop,squashfs,sd-mod,usb-storage quiet/modules=loop,squashfs,sd-mod,usb-storage console=tty1/' \
        "$BOOT_CONTENT/cmdline.txt" 2>/dev/null || true


      BOOT_CONTENT_MB=$(du -sm "$BOOT_CONTENT" | cut -f1)
      BOOT_SIZE_MB=$(( BOOT_CONTENT_MB + BOOT_CONTENT_MB / 10 + 10 ))
      echo "Boot content: ''${BOOT_CONTENT_MB}M, partition: ''${BOOT_SIZE_MB}M"
      truncate -s "''${BOOT_SIZE_MB}M" boot.img
      mkfs.vfat -F 32 -n ALPINE_BOOT boot.img

      MTOOLSRC="$PWD/mtoolsrc"
      echo "drive x: file=\"$PWD/boot.img\"" > "$MTOOLSRC"
      export MTOOLSRC

      for item in "$BOOT_CONTENT"/*; do
        mcopy -s -n "$item" x:/
      done


      DATA_SIZE_MB=128
      truncate -s "''${DATA_SIZE_MB}M" data.img
      mkfs.ext4 -F -L ALPINE_DATA data.img


      P1_END_MB=$(( 1 + BOOT_SIZE_MB ))
      P2_START_MB=$P1_END_MB
      P2_END_MB=$(( P2_START_MB + DATA_SIZE_MB ))
      TOTAL_MB=$(( P2_END_MB + 1 ))

      truncate -s "''${TOTAL_MB}M" disk.img

      echo "=== Disk layout: ''${TOTAL_MB}M total ==="
      echo "  p1: FAT32 ''${BOOT_SIZE_MB}M (Alpine boot + apkovl)"
      echo "  p2: ext4  ''${DATA_SIZE_MB}M (persistent /home)"

      parted -s disk.img mklabel msdos
      parted -s disk.img mkpart primary fat32 1MiB ''${P1_END_MB}MiB
      parted -s disk.img mkpart primary ext4 ''${P2_START_MB}MiB ''${P2_END_MB}MiB
      parted -s disk.img set 1 boot on

      parted -m disk.img unit B print | tail -n +3 | while IFS=: read n start end size type rest; do
        case "$n" in
          1) P1_START_BYTES=''${start%B}; P1_END_BYTES=''${end%B} ;;
          2) P2_START_BYTES=''${start%B}; P2_END_BYTES=''${end%B} ;;
        esac
        echo "Partition $n: $start - $end ($type)"
      done

      P1_START_BYTES=$(parted -m disk.img unit B print 2>/dev/null | awk -F: 'NR==3 {gsub(/B/,"",$2); print $2}')
      P2_START_BYTES=$(parted -m disk.img unit B print 2>/dev/null | awk -F: 'NR==4 {gsub(/B/,"",$2); print $2}')

      echo "Writing partition 1 (FAT32) at byte $P1_START_BYTES"
      dd if=boot.img of=disk.img bs=1 seek=$P1_START_BYTES conv=notrunc status=none

      echo "Writing partition 2 (ext4)  at byte $P2_START_BYTES"
      dd if=data.img of=disk.img bs=1 seek=$P2_START_BYTES conv=notrunc status=none

      echo "=== Final partition table ==="
      parted -s disk.img unit MiB print

      cp disk.img "$out"
    '';
in
{
  inherit apkovl bootPartitionDir deployScript diskImage;
}
