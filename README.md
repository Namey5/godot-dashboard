# Godot Dashboard
A simple version management app for (and written using) the Godot engine.
![dashboard](https://github.com/user-attachments/assets/8db59370-0ae2-4942-a91a-e227d2f9aeee)

Features:
 - List and download+install releases from the [official Godot github](https://github.com/godotengine/godot/releases).
 - Launch or uninstall local versions of Godot.
 - ...that's about it.

This is not meant to replace other Godot version managers. I had been using [Godot Manager](https://github.com/eumario/godot-manager) 
personally, but ran into some issues and honestly just wanted something a bit simpler so created my own.
At some point I might add centralised project management, but for now each install launches you directly into the official project manager
which I think is good enough.

Currently only supports `Linux/x86_64`, however other platforms should be trivially supportable by just extending the OS/architecture 
RegEx matrices in [download_model.gd](scripts/models/download_model.gd#L9) and [install_model.gd](scripts/models/install_model.gd#L6).

Made using Godot 4.3

Icons are CC0 licenced from https://kenney.nl/assets/game-icons
