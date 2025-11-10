# 🧙‍♂️ Mage Survivor Game

**Survivor-like hra** vytvořená v **Godot 4** s top-down pohledem, kde hráč ovládá mága bojujícího proti vlnám nepřátel.

## 🎮 Gameplay

### Cíl hry
- **Přežij co nejdéle** proti nekonečným vlnám nepřátel
- **Leveluj** a vylepšuj své schopnosti
- **Dosáhni co nejvyššího skóre** (čas přežití + zabití nepřátel)

### Ovládání
- **WASD / Šipky** - Pohyb
- **Virtuální joystick** - Mobilní ovládání (touch)
- **Automatický útok** - Mág automaticky útočí na nejbližší nepřátele

### Herní mechaniky
- ✅ **Automatické střílení** projektilů na nejbližší nepřátele
- ✅ **Level-up systém** - získávej EXP zabíjením nepřátel
- ✅ **Upgrade menu** - 3 náhodné upgrady při každém level upu
- ✅ **Rarity systém** - Common, Rare, Epic, Legendary upgrady
- ✅ **Luck stat** - ovlivňuje šanci na lepší upgrady
- ✅ **Rostoucí obtížnost** - nepřátelé jsou silnější a početnější každých 30s
- ✅ **HP regenerace** - pasivní léčení každou sekundu
- ✅ **Lifesteal** - získávej HP z poškození
- ✅ **Defense** - snižuj přijímané poškození

## 📊 Statistiky hráče

| Stat | Popis | Základní hodnota |
|------|-------|------------------|
| **Max HP** | Maximální zdraví | 100 |
| **HP Regen** | Regenerace HP/s | 2.0 |
| **Damage** | Poškození na projektil | 10 |
| **Projectile Count** | Počet projektilů na salvu | 1 |
| **Attack Speed** | Útoky za sekundu | 1.0 |
| **Move Speed** | Rychlost pohybu | 250 |
| **Defense** | Snížení damage (%) | 20% |
| **Lifesteal** | HP z damage (%) | 10% |
| **Luck** | Šance na lepší upgrady | 1.0 |

## 🎯 Upgrady

### Typy upgradů
1. **Damage** - Zvýší poškození projektilů
2. **Projectiles** - Přidá další projektily
3. **Max Health** - Zvýší maximální HP (+ okamžité léčení)
4. **Health Regen** - Zvýší regeneraci HP/s
5. **Attack Speed** - Zvýší rychlost útoků
6. **Move Speed** - Zvýší rychlost pohybu
7. **Lifesteal** - Zvýší % HP z poškození
8. **Defense** - Zvýší % snížení damage

### Rarity hodnoty

| Upgrade | Common | Rare | Epic | Legendary |
|---------|--------|------|------|-----------|
| **Damage** | +2 | +5 | +10 | +20 |
| **Projectiles** | +1 | +1 | +2 | +3 |
| **Max HP** | +10 | +25 | +50 | +100 |
| **HP Regen** | +2.0/s | +5.0/s | +10.0/s | +20.0/s |
| **Attack Speed** | +0.1/s | +0.25/s | +0.5/s | +1.0/s |
| **Move Speed** | +10 | +25 | +50 | +100 |
| **Lifesteal** | +5% | +10% | +20% | +40% |
| **Defense** | +5% | +10% | +15% | +30% |

## 🐛 Známé bugy
- ~~❌ HP regenerace nefunguje (OPRAVENO v/1.2)~~
- ⚠️ Vzácně mizí nepřátelé při level up (vyšetřuje se)

## 🚀 Plánované features

### Priorita 1 (Základ hry)
- [ ] **Více typů nepřátel** - létající, rychlí, tanky
- [ ] **Boss fights** - každých X minut
- [ ] **Dash ability** - úhybný manévr s cooldownem
- [ ] **Zkušenostní kameny** - posbíratelné EXP po smrti nepřátel
- [ ] **Pause menu** - ESC pro pauzu

### Priorita 2 (Polishing)
- [ ] **Zvukové efekty** - střílení, hit, smrt, level up
- [ ] **Hudba** - atmospheric background music
- [ ] **Particle efekty** - exploze, level up animace
- [ ] **Screen shake** - při zásahu/smrti
- [ ] **Damage numbers** - létající čísla damage
- [ ] **Minimap** - zobrazení hráče a nepřátel

### Priorita 3 (Meta-progressi)
- [ ] **Permanent upgrady** - meta-progressi mezi runy
- [ ] **Unlockable charaktery** - různé mágové s bonusy
- [ ] **Achievementy** - "Zabij 1000 nepřátel", "Přežij 20 minut"
- [ ] **Leaderboard** - ukládání high scores
- [ ] **Daily challenges** - denní výzvy s odměnami

### Priorita 4 (Gameplay rozšíření)
- [ ] **Více zbraní** - meč, luk, hůl s různými vzory střelby
- [ ] **Pasivní itemy** - např. "magnet" (větší pickup radius)
- [ ] **Active abilities** - ultimate schopnosti s dlouhým cooldownem
- [ ] **Evoluční upgrady** - kombinace 2+ upgradů = speciální upgrade
- [ ] **Arény/mapy** - různé biomy s překážkami

### Priorita 5 (Polish & Optimization)
- [ ] **Tutorial** - základní vysvětlení mechanik
- [ ] **Settings menu** - ovládání, audio, grafika
- [ ] **Save/Load systém** - pokračování ve hře
- [ ] **Optimalizace** - object pooling pro projektily/nepřátele
- [ ] **Mobile build** - APK export pro Android

## 🛠️ Technické info

### Struktura projektu
```
mage-game/
├── assets/
│   ├── player/          # Sprite sheets hráče
│   ├── enemies/         # Sprite sheets nepřátel
│   └── upgrades/        # Ikony upgradů
├── scenes/
│   ├── main.tscn        # Hlavní scéna
│   ├── mage.tscn        # Hráč
│   ├── enemy.tscn       # Nepřítel
│   ├── projectile.tscn  # Projektil
│   ├── level_up_menu.tscn
│   └── game_over_menu.tscn
└── scripts/
    ├── mage.gd
    ├── enemy.gd
    ├── projectile.gd
    ├── enemy_spawner.gd
    ├── level_up_menu.gd
    ├── game_over_menu.gd
    └── virtual_joystick.gd
```

### Engine
- **Godot 4.3+**
- **GDScript**

### Klíčové systémy
1. **Physics-based movement** - RigidBody2D pro hladký pohyb
2. **Auto-targeting** - projektily sledují nejbližší nepřátele
3. **Procedural spawning** - nepřátelé se spawnují kolem hráče
4. **Dynamic difficulty** - škálování každých 30s
5. **Upgrade system** - weighted random s luck modifikátorem

## 📝 Changelog

### v1.2 (Current)
- ✅ Opravena HP regenerace (sekundové ticky místo frame-based)
- ✅ Zvýšené hodnoty HP_REGEN upgradů
- ✅ Přidán check pro zastavení spawneru při level up

### v1.1
- ✅ Přidán level up menu systém
- ✅ Přidán rarity systém (Common → Legendary)
- ✅ Přidána luck mechanika
- ✅ Game over menu s statistikami

### v1.0
- ✅ Základní gameplay loop
- ✅ Auto-targeting projektily
- ✅ Enemy spawner s rostoucí obtížností
- ✅ Virtuální joystick pro mobily

## 👨‍💻 Autor
Vytvořeno s pomocí GitHub Copilot 🤖

## 📜 Licence
MIT License - use freely!
