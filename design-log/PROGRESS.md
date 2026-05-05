# Project Progress - Indice

> Last updated: 2026-05-05

---

## File di tracking

| File | Contenuto |
|------|-----------|
| [TODO.md](./TODO.md) | Cose da fare |
| [DONE.md](./DONE.md) | Lavoro completato |

---

## Stato rapido

- **Bug critici aperti:** 0
- **Prossima priorità:** **Fase 3 MCA2 extension** — 6 nuovi pass di rendering (Repeats, KeyChange, ClefChange, Fingering, Intra-staff voices, Tuplet ratio) + helper `MusicGlyph` triplo fallback
- **Design log attivi (cross-repo):** [VivaldiOCRScore/design-log/2026-05-05-extend-mca-musical-semantics.md](../../VivaldiOCRScore/design-log/2026-05-05-extend-mca-musical-semantics.md)

---

## Fasi completate

- ~~Progetto iniziale~~ (xcodeproj multiplatform, modello VivaldiScore standalone, editor UI, engine pentagramma 10-pass, 4 JSON esempio) → DONE 2026-04-10

---

## Cross-repo dependencies

Questo repo dipende da `VivaldiScoreKitPackage` per il modello e il rendering.
Quando il modello v2 (MCA2) è stato esteso il 2026-05-05 (vedi master design log), questo repo NON è stato ancora modificato. La Fase 3 — che modificherà QUESTO repo per visualizzare i nuovi field — è prossima.

---

## Quick Links

- [PROJECT.md](./PROJECT.md)
- [METHODOLOGY.md](./METHODOLOGY.md)
- [sessions/latest.md](./sessions/latest.md)
