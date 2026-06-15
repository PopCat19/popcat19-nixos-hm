# alpine-apk-bundle.nix
#
# Purpose: Resolve and download APK packages + transitive deps for offline
# Alpine diskless boot. Produces a directory aarch64/*.apk + APKINDEX.tar.gz
# that Alpine's initramfs detects and installs without network access.
#
# First-build directions (hash not yet pinned):
#   1. Set outputHash = "" below.
#   2. nix build .#alpine-klipper-img (will fail with hash mismatch)
#   3. Copy the "got:" hash from the error into outputHash.
#   4. Rebuild.
#
# After hash is pinned, subsequent builds are bit-for-bit reproducible.
{
  lib,
  stdenv,
  cacert,
  curl,
  gnutar,
  gzip,
  gawk,
}:
{
  packageList,
}:
let
  repoBase = "https://dl-cdn.alpinelinux.org/alpine/edge";
  repos = [
    "main"
    "community"
  ];

  seedContent = lib.concatStringsSep "\n" ([
    "alpine-baselayout"
    "openrc"
    "openssh-server"
    "dbus"
    "dbus-openrc"
  ] ++ packageList);

  resolver = ./alpine-apk-resolver.awk;
in
stdenv.mkDerivation {
  name = "alpine-apk-offline-bundle-aarch64";
  nativeBuildInputs = [
    cacert
    curl
    gnutar
    gzip
    gawk
  ];
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-y/HnSE5FrO4A81aOMRjikOAK0A3tpfKzzqiqE4KCHHM=";
  __structuredAttrs = false;

  buildCommand = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    mkdir -p "$out/aarch64"

    echo "=== Fetching APKINDEX ==="
    : > /tmp/apkindex
    for repo in ${lib.escapeShellArgs repos}; do
      url="${repoBase}/$repo/aarch64/APKINDEX.tar.gz"
      echo "Fetching $url"
      curl -sSL --retry 3 "$url" | tar xz -O APKINDEX >> /tmp/apkindex
    done
    echo "APKINDEX: $(wc -l < /tmp/apkindex) lines"

    echo "=== Writing seed packages ==="
    cat > /tmp/seed << 'SEED_EOF'
${seedContent}
SEED_EOF

    echo "=== Resolving dependencies ==="
    gawk -v seed=/tmp/seed -f ${resolver} /tmp/apkindex 2>/tmp/unresolved > /tmp/resolved
    resolved_count=$(wc -l < /tmp/resolved)
    echo "Resolved $resolved_count packages"
    head -20 /tmp/resolved
    if [ -s /tmp/unresolved ]; then
      echo "Unresolved:"
      head -20 /tmp/unresolved
    fi

    echo "=== Downloading APK files ==="
    idx=0
    while read -r pkg ver origin repo_tag; do
      [ -z "$pkg" ] && continue
      [ -z "$origin" ] && origin="$pkg"
      fname="$origin-$ver.apk"
      idx=$((idx + 1))
      echo -n "  [$idx/$resolved_count] $pkg -> $fname"
      for repo in main community; do
        url="${repoBase}/$repo/aarch64/$fname"
        curl -sSL --fail --retry 1 "$url" -o "$out/aarch64/$fname" 2>/dev/null && break
        rm -f "$out/aarch64/$fname"
      done
      size=$(stat -c%s "$out/aarch64/$fname" 2>/dev/null || echo 0)
      if [ "$size" -lt 1000 ]; then
        echo " (ERROR: $size bytes)"
        rm -f "$out/aarch64/$fname"
      else
        echo " (OK: $size bytes)"
      fi
    done < /tmp/resolved

    echo "=== Building APKINDEX.tar.gz ==="
    cd "$out/aarch64"
    : > /tmp/local-index
    for f in *.apk; do
      [ "$f" = "*.apk" ] && continue
      pkg_name=''${f%-[0-9]*.apk}
      pkg_name=''${pkg_name%-r[0-9]*}
      pkg_name=''${pkg_name%-r[0-9]*}
      grep -qxF "P:$pkg_name" /tmp/local-index 2>/dev/null && continue
      {
        echo "P:$pkg_name"
        sed -n "/^P:$pkg_name\$/,/^\$/p" /tmp/apkindex
        echo ""
      } >> /tmp/local-index
    done
    tar czf APKINDEX.tar.gz -C /tmp local-index

    echo "=== Done: $(ls *.apk 2>/dev/null | wc -l) APK files ==="
  '';
}
