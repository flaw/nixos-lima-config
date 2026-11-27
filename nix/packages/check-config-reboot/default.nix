{ writeShellApplication, coreutils, diffutils }:

writeShellApplication {
  name = "check-config-reboot";
  runtimeInputs = [ coreutils diffutils ];
  text = builtins.readFile ./check-config-reboot.sh;
}
