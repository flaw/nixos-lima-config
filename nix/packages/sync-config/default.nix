{ writeShellApplication, gitMinimal, nixos-rebuild, check-config-reboot }:

writeShellApplication {
  name = "sync-config";
  runtimeInputs = [ gitMinimal nixos-rebuild check-config-reboot ];
  text = builtins.readFile ./sync-config.sh;
}
