# Blackout Hack by Grok

An ultimate Roblox script for Blackout mode with Silent Aim, AimLock, Target ESP, Fling, custom Kill Sounds, and color-based Skybox, powered by Rayfield UI.

## Features
- **Silent Aim**: Customizable FOV, target part (Head, Torso, HumanoidRootPart, Random), hitmarker (visual + sound), with Raycast and RemoteEvent hooks.
- **AimLock**: Smooth camera lock with customizable FOV, smoothness, and target part.
- **ESP**: 3D Box, Glow Chams, Skeleton, Healthbar with gradient, Nickname, Tracers, Target Line (to aim target), Self Chams for hands/weapon (transparent, customizable).
- **Misc**: Fly, Noclip, Chat Spammer, Spinbot, Fling (yeets nearby players to space), Custom Crosshair, Kill Effects (custom sound ID), Teleport (auto-updating player list), Chat Viewer, Skybox (color-based via ColorPicker).
- **Configs**: Save/load settings in JSON format.
- **UI**: Rayfield Interface with clear sections, toggles, sliders, color pickers, dropdowns, and input fields.

## Installation
1. Install a Roblox exploit (e.g., Synapse X, Krnl).
2. Copy the script from `script.lua`.
3. Inject the script into Roblox while in Blackout mode.
4. Press the keybind (default: `Insert`) to open the UI.

## Usage
- **Aim Tab**: Enable Silent Aim or AimLock, adjust FOV, smoothness, target part, toggle hitmarker.
- **ESP Tab**: Enable 3D Box, Chams, Skeleton, Healthbar, Nickname, Tracers, Target Line, Self Chams.
- **Misc Tab**: Fly, Noclip, Chat Spam, Spinbot, Fling, Crosshair, Kill Effects (custom sound ID), Teleport, Chat Viewer, Skybox (choose color).
- **Configs Tab**: Save/load settings for quick setup.

## Customization
- Adjust colors for ESP, FOV, Crosshair, Self Chams, Target Line, Skybox via UI.
- Set custom `rbxassetid://` for Kill Effects sound (e.g., `rbxassetid://9040396266` for headshot).
- Modify Fly Speed, Smoothness, Chams Transparency via sliders.
- Edit `script.lua` for advanced tweaks (fully commented).

## Notes
- No autoload, no keys, fully editable.
- Optimized for Blackout mode; no anti-cheat issues reported.
- Skybox uses `Lighting.Ambient` and `OutdoorAmbient` for solid color, no `rbxassetid://` required.
- Find sound IDs in Roblox Library (search "headshot sound").
- Fling may cause server lag if overused; toggle off when not needed.
- Silent Aim requires game-specific RemoteEvent names for full accuracy (see debugging tips).
- Submit bugs or feature requests via GitHub Issues.

## Credits
- Created by Grok (xAI)
- Powered by Rayfield Interface Library
