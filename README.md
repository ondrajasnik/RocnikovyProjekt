# Mage Game

## Overview
Mage Game is a 2D side-view game where players control a Mage character with unique abilities and statistics. The game features various environments, visual effects, and a user-friendly interface.

## Project Structure
The project is organized into the following directories and files:

- **assets/**
  - **characters/**: Contains sprite sheets and animations for the Mage character and other characters in the game.
  - **effects/**: Includes visual effects assets such as particle systems and spell effects.
  - **tilesets/**: Holds tilemaps and tileset images used for the game environment.

- **scenes/**
  - **main.tscn**: The main scene of the game, serving as the entry point and containing the game world and UI elements.
  - **mage.tscn**: Defines the Mage character, including its animations and properties.
  - **ui.tscn**: Contains the user interface elements such as health bars, mana bars, and ability buttons.

- **scripts/**
  - **mage.gd**: Defines the `Mage` class, including properties like health, mana, and methods for movement, casting spells, and taking damage.
  - **abilities.gd**: Manages the abilities of the Mage, defining different spells and their effects, including methods for casting and cooldown management.
  - **main.gd**: The main game controller, handling game initialization, scene transitions, and overall game logic.

- **project.godot**: The project configuration file for Godot, containing settings and metadata for the game project.

## Setup Instructions
1. Clone the repository or download the project files.
2. Open the project in Godot 4.
3. Ensure all assets are correctly linked in the scenes.
4. Run the `main.tscn` scene to start the game.

## Gameplay Mechanics
- Players control the Mage character using keyboard inputs.
- The Mage can cast spells, move around the environment, and interact with objects.
- Health and mana are displayed on the user interface, and players must manage these resources to succeed.

## Credits
- Developed by [Your Name]
- Special thanks to the Godot community for their support and resources.