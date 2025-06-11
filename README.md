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

📅 Fáze 3 – Postup vývoje

1:

Navrhnout schéma databáze (Users, Videos, History, Payments)

Založit Node.js projekt, propojit MongoDB

Přidat registraci a přihlášení (JWT)


2:

Přidat upload videí + metadata (kategorie, popis)

Nahrávání přes Multer, ukládání na disk nebo cloud

Zobrazit seznam videí


3:

Přidat přehrávání videí (Video.js nebo vlastní player)

Uložit historii sledování do DB

Omezit přístup na 2 videa denně zdarma


4:

Přidat platební bránu (Stripe, ČSOB API)

Uživatel si může koupit jedno video (20 Kč) nebo měsíční předplatné

Přidat správu uživatelů (administrace)


🔐 Fáze 4

Přidání dynamického vodoznaku: jméno uživatele overlay na video (ffmpeg + transparentní vrstvy nebo Video.js plugin)

Streaming přes HLS (přes .m3u8 soubory) – ztíží stažení

Blokování pravého kliknutí, F12, konzole (částečně, frontendové)

Možnost DRM (Widevine) v budoucnu – složité, nepovinné


💡 Extra funkce pro body navíc

Komentáře pod videi

Hvězdičkové hodnocení

Oblíbená videa

Filtr podle úrovně (začátečník/pokročilý)
