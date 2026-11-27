{ pkgs }:

let
  check-config-reboot = pkgs.callPackage ./check-config-reboot { };
in
{
  inherit check-config-reboot;
  sync-config = pkgs.callPackage ./sync-config { inherit check-config-reboot; };
}
