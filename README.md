# nix
Nix Flakes used for development environments.

### Structure
Each host reads from a base configuration, and then picks-and-chooses setups from `modules/` based on what it is meant to do. For instance:
* `default` is my home desktop which has everything: gaming, development, local LLM etc.
* `laptop` has limited resources and has no local LLM capability
* `wsl` lacks any Linux desktop setup because all the UI and such is provided by Windows

# Notes:
Hardware configuration: ensure that the hardware configuration does NOT generate a Docker file system. This will cause
the system to reboot into emergency mode. 28/03/2025 worst day of my life.

https://discourse.nixos.org/t/docker-switch-overlay-overlay2-fs-lead-to-emergency-console/29217/2

