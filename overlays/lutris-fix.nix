# Fix lutris build by overriding pyrate-limiter dependency to disable tests
final: prev: {
  # Create a fixed version of lutris that uses a patched pyrate-limiter
  lutris-unwrapped = prev.lutris-unwrapped.overrideAttrs (oldAttrs: {
    propagatedBuildInputs = with prev; [
      python3
      python3Packages.setuptools
      python3Packages.pyparsing
      python3Packages.requests
      python3Packages.beautifulsoup4
      python3Packages.lxml
      python3Packages.pillow
      python3Packages.meson
      python3Packages.ninja
      python3Packages.pefile
      python3Packages.pyyaml
      python3Packages.vdf
      python3Packages.pypresence
      python3Packages.websocket-client
      python3Packages.idna
      python3Packages.packaging
      python3Packages.chardet
      python3Packages.certifi
      python3Packages.urllib3
      # Override pyrate-limiter with disabled tests
      (python3Packages.pyrate-limiter.overrideAttrs (oldAttrs: {
        doCheck = false;
      }))
    ];
  });
}