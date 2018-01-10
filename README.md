# Athenaeum
Addon for World of Warcraft (3.3.5) - Collection of modules with various functionality

## Modules
This addon is using a modular approach to organizing its features.
Modules can be found in `Athenaeum/modules` folder.

You can list available modules in-game using `/at list` command.

All modules are disabled by default and enabled state is not persisted across sessions.
However, this can be changed by setting **isPreserved** property to **true** at *Config.PropertyEnabled* table in `Athenaeum/core/config.lua` file.

In order to toggle module in-game use `/at module [name]` command.

### Morph

A user-interface for the .morph command that changes the model of the selected entity.
You can quickly change and preview modules in-game.

Left clicking on buttons changes model ID by one, right-clicking by 10, this can be changed in the configuration using `/at config morph step [value]` and `/at config morph jump [value]` commands.

To enable/disable this module use `/at module morph` command.
To list configuration properties of this module use `/at config morph` command.

### Gps

A user-interface for the .gps command that shows the on-screen overlay with selected entity coordinates and orientation.

Refresh interval is 3 seconds by default, use `/at config refresh [value]` command to change it.
What property is visible in the overlay can be set using `/at config show-[property] [true/false]` command.
Coordinates rounding accuracy can be changed using `/at config accuracy [value]` command.

To enable/disable this module use `/at module gps` command.
To list configuration properties of this module use `/at config gps` command.

## Configuration

Most modules have properties that can be changed in-game using configuration commands.
To list configuration properties of all modules use `/at config` command, to list properties of given module use `/at config [module]`.
Properties can be set by using `/at config [module] [property] [value]` command.
Any property can be reset to default value by `/at config [module] [property] default`.
