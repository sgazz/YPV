# XOArena3D - 3D Skakač s Motkom

## O projektu
XOArena3D je 3D platformer igra koja simulira realističnu mehaniku skoka s motkom (pole vaulting). Igra koristi naprednu fizičku simulaciju za autentičan doživljaj skakanja s motkom.

## Realistična mehanika skoka s motkom

### 🎯 Ključni fizički principi

#### 1. **Početni zalet i držanje motke**
- **Realni ugao**: Motka se drži pod uglom od 60-70° prema horizontali
- **Implementacija**: Automatska rotacija motke na -60° kada igrač trči
- **Fizički razlog**: Optimalan balans između horizontalnog momenta i vertikalne stabilnosti

#### 2. **Kontakt sa zemljom i pivot tačka**
- **Realni kontakt**: Donji kraj motke ulazi u "box" (udubljenje)
- **Implementacija**: Fiksna pivot tačka na 2.5m ispred igrača
- **Fizički princip**: Sva rotacija se dešava oko ove tačke

#### 3. **Elastičnost i SpringJoint simulacija**
- **Realna elastičnost**: Fiberglas motka se ponaša kao opruga
- **Implementacija**: Hooke's Law (F = -kx) sa prigušenjem
- **Fizički parametri**:
  - Spring constant: 25 N/m
  - Damping: 0.6
  - Maksimalna kompresija: 2.0m

#### 4. **Pretvaranje energije**
- **Horizontalna → Vertikalna**: Kinetička energija se pretvara u potencijalnu
- **Formula**: E = ½mv² → E = ½kx²
- **Koeficijent pretvaranja**: 70% horizontalne energije

#### 5. **Optimalan timing za odraz**
- **Realni timing**: 75% kompresije motke
- **Implementacija**: Automatski odraz kada je dostignut optimalan ugao (85°)
- **Vizuelni indikator**: Zelena boja motke za optimalan timing

### 🔧 Napredne fizičke simulacije

#### SpringJoint simulacija
```gdscript
# Hooke's Law implementacija
var spring_force = -pole_spring_constant * pole_spring_compression
var damping_force = -pole_damping_constant * pole_spring_velocity
var total_force = spring_force + damping_force + wind_force + weight_force
```

#### Realistični efekti
- **Wind resistance**: Otpor vazduha na motku
- **Pole weight**: Težina motke utiče na igrača
- **Momentum transfer**: Prenos momenta sa motke na igrača
- **Optimal timing**: Automatsko prepoznavanje najboljeg trenutka za odraz

### 🎮 Kontrole

| Kontrola | Akcija |
|----------|--------|
| WASD | Kretanje |
| Desni klik miša | Trčanje |
| SPACE | Običan skok |
| Levi klik miša | Skakanje s motkom |
| ESC | Izlaz iz igre |

### 🏆 Sistem bodovanja

- **Kretanje**: 10 poena po metru
- **Skakanje s motkom**: Bonus poeni na osnovu uskladištene energije
- **Pad**: -100 poena

### 🎨 Vizuelni efekti

#### Kompresija motke
- **Crvena boja**: Intenzitet kompresije
- **Zelena boja**: Optimalan timing za odraz
- **Oscilacija**: Realistično "stresanje" motke

#### Savijanje motke
- **Scale animacija**: Simulacija savijanja
- **Rotacija**: Dodatni realistični efekti
- **Stres efekat**: Mikro-rotacije tokom kompresije

### 🔬 Tehnički detalji

#### Fizički konstante
```gdscript
var GRAVITY = 20.0
var POLE_ELASTIC_CONSTANT = 15.0
var POLE_DAMPING = 0.8
var HORIZONTAL_TO_VERTICAL_RATIO = 0.7
var pole_spring_constant = 25.0
var pole_damping_constant = 0.6
var wind_resistance = 0.02
var pole_weight = 2.0
```

#### Algoritam skoka s motkom
1. **Zabijanje**: Motka se rotira na 60° i zabija u zemlju
2. **Kompresija**: SpringJoint simulacija kompresije
3. **Energija**: Akumulacija kinetičke energije
4. **Timing**: Provera optimalnog trenutka (75% kompresije)
5. **Odraz**: Automatski odraz sa prenosom momenta
6. **Let**: Parabolična putanja sa realističnom visinom

### 🚀 Buduća unapređenja

- [ ] Dodavanje zvukova (pole plant, compression, release)
- [ ] UI indikator za timing
- [ ] Različite vrste motki sa različitim karakteristikama
- [ ] Multiplayer mod
- [ ] Level editor
- [ ] Achievement sistem

### 📊 Performanse

- **FPS**: Stabilno 60 FPS na srednjim računarima
- **Fizička simulacija**: Optimizovana za real-time performanse
- **Memory usage**: Minimalno korišćenje memorije

---

**Napomena**: Ova implementacija je zasnovana na realnim fizičkim principima skoka s motkom i pruža autentičan doživljaj ovog sporta u 3D okruženju.
