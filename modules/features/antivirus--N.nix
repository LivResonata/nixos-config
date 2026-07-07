{ ... }:

{
  flake.nixosModules.antivirus =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        clamtk # Front-end ClamAV GUI
      ];

      services.clamav = {
        daemon.enable = true;
        clamonacc.enable = true;

        scanner = {
          enable = false;
          interval = "monthly";

          scanDirectories = [
            "/home"
            "/var/lib"
            "/etc"
          ];
        };

        # Official database
        updater = {
          enable = true;
          interval = "weekly";
          frequency = 6;
        };

        # Additional "freshly caught" non-official sources
        fangfrisch = {
          enable = true;
          interval = "weekly";
        };
      };
    };
}
