This is a collection of non-dotfile configuration files.

## canonicalize-subdomains.conf

Modify as needed with your local subdomains and put in
`/etc/ssh/ssh_config.d/` (at least on Debian-based systemd) so that `ssh` will
normalize hostnames for `known_hosts`.

## firefox-hide-tabs-userChrome.css

For use with Tree Style Tabs. Copy this file to
`${FIREFOX_PROFILE}/chrome/userChrome.css`. Find `${FIREFOX_PROFILE}` with by
going to `about:support`, then clicking the "Open Folder" button for the
"Profile Folder". You may need to create teh `chrome` directory.

You will also need to open `about:config` and set
`toolkit.legacyUserProfileCustomizations.stylesheets` to `true`.

## windows-terminal-settings.json

This is the settings file for the new [Windows Terminal][win-terminal].
Settings syunc was disabled as the settings are still pretty host-specific.
Copy the settings file to
`%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_[random ID]\LocalState\settings.json`
(do Win-R, then copy paste up through `Packages` in the above path).

[win-terminal]: https://github.com/microsoft/terminal

## Windows Registry Files

### windows-disable-cortana.reg
Disable Cortana in Windows 10.

### windows-remap-capslock-escape.reg
Remaps Caps Lock to Escape. This will require a restart to take effect.

### windows-utc-clock.reg
Have Windows treat the hardware clock as a UTC clock, like Linux and macOS do by
default. Useful for dual-booting.
