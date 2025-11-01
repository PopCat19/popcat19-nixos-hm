let
  # Your SSH keys
  popcat19 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvtrt7vEbXSyP8xuOfsfNGgC99Y98s1fmBIp3eZP4zx popcat19@nixos";
  popcat19_builder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKan/AxlStNQIkJD0m4uxoKf2rJJz8cfwkRvOIJS+TBj popcat19@popcat19-nixos0";

  # nixos0's host key
  nixos0 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1yA6beqNqxgrbiZF+J5rZZy2PtT9/+Gfym78xsnAkF root@nixos";

  # All users/machines that can decrypt
  allUsers = [popcat19_builder];
  allSystems = [nixos0];
in {
  "github-nix-ci/PopCat19.token.age".publicKeys = allUsers ++ allSystems;
}
