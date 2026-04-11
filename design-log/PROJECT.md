# VivaldiScoreEditor — Editor visuale per VivaldiScore

## Vision

App macOS/iPad per creare, visualizzare e editare file VivaldiScore JSON — il formato proprietario per esercizi musicali della suite Vivaldi. Include un engine di rendering pentagramma che diventerà libreria condivisa usata anche da Workshop, Keyboard e altre app della suite.

## Tech Stack

| Tecnologia    | Dettagli                           |
|---------------|-----------------------------------|
| Linguaggio    | Swift 5/6                         |
| UI            | SwiftUI (NO Storyboard)           |
| Target        | macOS 15+ / iOS 18+               |
| Xcode         | 26.4                              |
| Rendering     | SwiftUI Canvas (multi-pass)       |
| Persistenza   | File JSON (Codable)               |
| Bundle ID     | it.gouttedeau.vivaldiscoreeditor  |

## Architecture Overview

### Funzionalità Principali

1. **Editor JSON** — Apri/salva file VivaldiScore (singolo, array, ScorePack)
2. **Staff Preview** — Rendering pentagramma in tempo reale con Canvas multi-pass
3. **Event Editor** — Modifica eventi (durata, pitch, rest, dotted, tie, slur, gruppi)
4. **Pack Manager** — Gestione pack di esercizi (più score in un file)

### Engine di Rendering (10 pass)

| Pass | Cosa renderizza |
|------|-----------------|
| 1 | Righe pentagramma |
| 2 | Chiave di violino |
| 3 | Armatura di chiave (diesis/bemolli) |
| 4 | Stanghette di battuta |
| 5 | Note: teste, gambi, ledger lines, punti — NO flag per beamate |
| 6 | Beams: barre condivise + barre parziali (mixed beaming) |
| 7 | Brackets/numeri per gruppi irregolari (3, 5, 6, 7) |
| 8 | Ties (legature di valore, anche cross-bar) |
| 8b | Slurs (legature di frase, multi-nota, cross-bar) |
| 9 | Etichette pitch |
| 10 | Numeri gruppo sopra beam |

### Formato VivaldiScore

- `ScoreType`: rhythm, pitch, mixed
- `ScoreEvent`: duration, isRest, pitch, dotted, tieToNext, slurLength, groupId/groupType/groupPosition
- `GroupType`: beam, triplet, quintuplet, sextuplet, septuplet
- `ScoreKeySignature`: fifths (-7...+7) + mode (major/minor)
- `ScoreMetadata`: difficulty, tags, suggestedBPM, notes, source

## Key Files

```
VivaldiScoreEditor/
├── VivaldiScoreEditorApp.swift    # Entry point
├── VivaldiScore.swift             # Modello dati (standalone Codable)
├── ScoreDocument.swift            # Manager file (load/save/pack)
├── ContentView.swift              # NavigationSplitView (sidebar + detail)
├── ScoreDetailView.swift          # Editor campi + bars + JSON preview
├── ScoreStaffPreview.swift        # Engine rendering pentagramma (Canvas)
├── NoteIconView.swift             # Icone nota per badge (Canvas)
└── examples/                      # File JSON di esempio
    ├── sample_pack.json           # Pack 3 score (base)
    ├── complex_a_major.json       # La maggiore complesso (9 battute)
    ├── advanced_groups.json       # Sestine, settine, quintine (8 battute)
    └── mixed_beaming.json         # Beaming misto (croma puntata + terzina biscrome)
```

## Conventions

- Naming: PascalCase per tipi, camelCase per variabili
- Il modello VivaldiScore è una copia standalone (no dipendenze da Workshop L10n)
- L'engine di rendering sarà estratto in package condiviso in futuro

## Getting Started

1. Aprire `VivaldiScoreEditor.xcodeproj` in Xcode 26
2. Target: macOS o iPad Simulator
3. Build & Run
4. File > Open > `examples/complex_a_major.json`
