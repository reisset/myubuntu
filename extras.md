# Extra steps i had to take in order to get ulauncher functional : 
## My Uploaded configs are the source of truth for shortcuts -> Scaffold according to those. 
### Installing gnome-sushi via APT.

### Following the instructions for wayland (ubuntu default)

Fedora and Ubuntu (since 17.04) start Wayland session by default. Ulauncher in Wayland does not receive hotkey events when triggered from some windows (like terminal or OS Settings).

Please follow these steps to fix that:

Install package wmctrl (needed to activate app focus)
Open Ulauncher Preferences and set hotkey to something you'll never use (I set mine to CTRL+Page down)
Open Settings > Keyboard (may be named "Keyboard Shortcuts"), then scroll down to Customize Shortcuts > Custom Shortcuts > +
In Command enter ulauncher-toggle, set name and shortcut, then click Add.

|
|
### This worked , and now i have a custom gnome shortcut to open ulauncher with super+space. I have also added ulauncher extensions (2).

--- 

- I also configured my keybindings to be essentially indentical to stock ubuntu experience for ease of use -- and adapatability. The main criteria i'd like to follow is that my currently pinned apps to the dock remain the same across all installations, and the dock should only appear at the bottom of the screen when users press "super" once, to bring up the default gnome menu (JUST LIKE OMAKUB).
