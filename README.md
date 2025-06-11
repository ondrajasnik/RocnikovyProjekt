🗂️ Fáze 1 – Základní návrh

🎯 Cíl:

Vytvořit webovou aplikaci pro přehrávání výukových videí s účty, historií, vyhledáváním a přehrávačem.

📌 Funkce:

Registrace a přihlášení uživatelů

Upload videí (pouze administrátor)

Kategorizace (např. Matematika, Programování, Fyzika)

Vyhledávání (podle názvu, popisu, kategorie)

Přehrávač videí

Historie sledování

Omezení: 2 videa denně zdarma

Prémiový účet: neomezený přístup

Ochrana videí (vodoznak, zabránění stahování)


⚙️ Fáze 2 – Technický stack

🧠 Backend:

Node.js + Express – API pro autentizaci, metadata, streamování

MongoDB – ukládání uživatelů, videí, historie sledování, plateb

Mongoose – ORM pro MongoDB

JWT (JSON Web Token) – přihlašování a správa sessions

Multer / Cloudinary / S3 – nahrávání a ukládání videí

ffmpeg – konverze videí, přidávání vodoznaku

Stripe nebo ČSOB API – platby


💻 Frontend:

React.js (nebo čistý HTML + JS) – přehrávač, formuláře, přehled videí

HLS.js – bezpečné streamování přes HLS

Tailwind CSS – stylování

Video.js – přehrávání + vodoznak (např. jméno uživatele přes overlay) 
