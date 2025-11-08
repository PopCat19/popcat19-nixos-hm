# Fix moddb build by overriding pyrate-limiter dependency
final: prev: {
  python313Packages = prev.python313Packages.extend (self: super: {
    # Override pyrate-limiter to disable tests
    pyrate-limiter = super.pyrate-limiter.overrideAttrs (oldAttrs: {
      doCheck = false;
    });
    
    # Also override moddb to use the fixed pyrate-limiter
    moddb = super.moddb.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = with self; [
        requests
        beautifulsoup4
        pyrate-limiter
        pyparsing
      ] ++ (oldAttrs.propagatedBuildInputs or []);
    });
  });
}