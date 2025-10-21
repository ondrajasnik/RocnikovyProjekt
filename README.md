<<<<<<< HEAD
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
=======
🗂️ Fáze 1 – Základní návrh

🎯 Cíl:
Vytvořit mobilní idle RPG hru, kde hráč bojuje s nepřáteli, získává zlato/exp a vylepšuje svého hrdinu.

📌 Funkce:

Klikání → útok na nepřítele

Idle útoky → hrdina útočí i bez klikání

Zlato a expy → odměna za poraženého nepřítele

Upgrady → zvýšení dmg, auto-útoků, HP

Uložení postupu → pokračování po vypnutí



---

🗂️ Fáze 2 – Technický stack

🧠 Engine / Framework:

Flutter – UI, multiplatformní vývoj

Flame – game engine pro Flutter (sprite animace, game loop, kolize)


💾 Data:

SharedPreferences – ukládání postupu hry

(volitelně SQLite, pokud budeš chtít složitější ukládání)


🎨 Grafika a zvuk:

Sprity hrdiny, nepřátel a ikon upgradů (volně dostupné, nebo vlastní)

Jednoduché zvukové efekty (útok, level up, porážka nepřítele)



---

🗂️ Fáze 3 – Postup vývoje

1️⃣ Základní mechanika

Vytvořit hrdinu + nepřítele

Kliknutí → nepřítel ztrácí HP

Když HP = 0 → nový nepřítel + odměna


2️⃣ Idle mechanika

Přidat automatické útoky (časovač → dmg každou sekundu)


3️⃣ Upgrady

Panel upgradů (damage, auto-útok, HP)

Cena upgradů roste exponenciálně


4️⃣ Uložení hry

SharedPreferences – zlato, level, upgrady se uloží při zavření aplikace



---

🗂️ Fáze 4 – Rozšíření

🔐 Pokročilé funkce:

Bossové (silnější nepřítel po X levelech)

Více lokací (les, jeskyně, hrad) → mění se grafika nepřátel

Inventář (meče, brnění) → přidávají bonusy

Animace útoků (Flame sprity nebo jednoduché efekty)

Zvukové efekty a hudba


💡 Extra body navíc:

Statistiky (kolik nepřátel bylo poraženo, nejvyšší level)

Achievementy (např. „zabil 100 nepřátel“)

Online žebříček (Firebase / REST API) – nepovinné
>>>>>>> 0e7eaeb6d6fdc1b6babb299d9c07ef378c55c04c
