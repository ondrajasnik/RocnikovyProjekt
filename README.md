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
