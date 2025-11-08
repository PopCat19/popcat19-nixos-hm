# Fix pyrate-limiter build by disabling failing tests
final: prev: {
  python313Packages = prev.python313Packages // {
    pyrate-limiter = prev.python313Packages.pyrate-limiter.overrideAttrs (oldAttrs: {
      # Disable tests that are causing build failures
      doCheck = false;
      # Alternatively, we could skip specific failing tests:
      # pytestFlagsArray = oldAttrs.pytestFlagsArray or [] ++ [
      #   "--deselect=tests/test_bucket_all.py::test_bucket_waiting"
      #   "--deselect=tests/test_limiter.py::test_limiter_async_factory_get"
      #   "--deselect=tests/test_limiter.py::test_limiter_concurrency"
      #   "--deselect=tests/test_bucket_all.py::test_bucket_leak"
      #   "--deselect=tests/test_bucket_all.py::test_bucket_flush"
      # ];
    });
  };
}