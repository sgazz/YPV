# XOArena3D - 3D Igra u Godot-u

Jednostavna 3D igra napravljena u Godot 4.4 engine-u.

## Opis igre

XOArena3D je 3D platformer igra gde igrač kontroliše karakter koji se može kretati po 3D prostoru. Cilj je da skupite što više poena kretanjem po areni.

## Kontrole

- **WASD** ili **Strelicama** - Kretanje (napred, levo, nazad, desno)
- **SPACE** - Skakanje (pritisnite dok ste na platformi)
- **Miš** - Rotacija kamere (pogled)
- **ESC** - Oslobađanje/zatvaranje miša

## Funkcionalnosti

- **3D kretanje** - Igrač se može kretati u svim pravcima
- **Skakanje** - Možete skakati preko prepreka
- **Sistem bodovanja** - Dobijate poene za kretanje
- **Prepreke** - Različite boje kutija kao prepreke
- **Fizika** - Realistična gravitacija i kolizije
- **Kamera** - Prva osoba kamera koja prati igrača

## Kako pokrenuti

1. Otvorite Godot 4.4 editor
2. Učitajte projekat (otvorite `project.godot` fajl)
3. Pritisnite F5 ili kliknite "Play" dugme
4. Igra će se pokrenuti u novom prozoru

## Struktura projekta

```
xoarena3d/
├── scenes/
│   └── Main.tscn          # Glavna scena igre
├── scripts/
│   └── Main.gd            # Glavna skripta za kontrolu igre
├── project.godot          # Konfiguracija projekta
└── README.md              # Ovaj fajl
```

## Razvoj

Ova igra je napravljena kao osnova za dalji razvoj. Možete dodati:

- Više nivoa
- Različite vrste prepreka
- Power-up-ove
- Zvukove i muziku
- Više igrača
- Različite vrste oružja
- AI protivnike

## Tehnički detalji

- **Engine**: Godot 4.4
- **Jezik**: GDScript
- **Render**: Forward Plus
- **Fizika**: Built-in Godot physics
- **Platforma**: Cross-platform (Windows, macOS, Linux)

## Licenca

Ovaj projekat je otvorenog koda i možete ga slobodno modifikovati i distribuirati.
