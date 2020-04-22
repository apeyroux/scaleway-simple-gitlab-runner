{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "console=ttyS0,115200"          # allows certain forms of remote access, if the hardware is setup right
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];

  networking.hostName = "gitlab-runner.px.io";

  networking.useDHCP = false;
  networking.interfaces.ens2.useDHCP = true;

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  time.timeZone = "Europe/Paris";

  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];

  services.openssh.enable = true;
  services.fail2ban.enable = true;

  programs.mosh.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = true;

  services.gitlab-runner = {
    enable = true;
    configOptions = {
      concurrent = 1;
      runners = [
        {
          name = "gitlab-runner.px.io";
          url = "https://code.minsi.fr/";
          token = "xxx";
          executor = "docker";
          docker = {
            image = "docker";
            volumes = ["/tmp/ci-certs:/certs/client" "/tmp/docker-ci:/docker-ci" "/tmp/ci-cache:/cache"];
            privileged = true;
          };
        }
      ];
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
  };

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjI+cLq05P+BVokJa9MCZK3WniQ/0Bl1gTc5NeH4CuG92qPhTT617IAf8qr6+J5Vy4tFhF3LfyuqlUey6X2oyXlOhz7lDR5q7Wpe/piwSIu1HMQ6iCxbUrZlklMErO24cl0tguVXoq3k9rVPOtlOkCp2YKz5pir8fsJon+CHsuJf+A9aUydK0qVPIxOAiRBjWrQun83mM2t3CkcvSEpjA7JmuzCvbbpiUudmnQz0HqIc4dDSbmkuNMpdqoqGoDkmcNLOYppt5LYDEQZO8EEPXXDSX0fHdTmm6e9Nrjfh2jrquP2NOFLtffEcVrRR5HLNAQCC1seqhyTS4MIDOu+TWCm3JI0WTdaIO2WCItCDFc4Q2Rad5XGD3WFe2I+uB0rhrpu2+Ens5UXTgHB3aXhHEo7F61ZO5SzLHvd4eNvsCaIljVx4Ces0N3Ttxg4yXxVMF8XejQxikx2F6Mx/+dzd0LQQh/B72suOfx/Dbmhrt3VG65E+WtJ6fQ0vOtkZn5h8xAqN6v1wfbpm2WXMUp3IGfV4mo7wEsyHGgj6tpLL1UcIfP4c1iC3bORwGgFWvHgcc7lJZt2EMoo9jekLD/MAvdzT13iWpljGaZ0JwpElhVoQ4IQhEnPgPRyWYhkaAdywqERUggPPqgKaa6CuSaM1uqCUKqqa/pUJR1lX7dpdkeJQ== alex@laptop" ];
  };  

  system.stateVersion = "19.09"; # Did you read the comment?

}
