# Fix mangojuice hash mismatch
# The NUR package has an incorrect hash for version 0.8.9
final: prev: {
  mangojuice = prev.mangojuice.overrideAttrs (oldAttrs: {
    version = "0.8.9";
    src = prev.fetchFromGitHub {
      owner = "radiolamp";
      repo = "mangojuice";
      tag = "0.8.9";
      hash = "sha256-12bsiy1yxnqnkm703hdwnsixk30513dm2rl4r0qwwqrn98yq8m4f=";
    };
  });
}