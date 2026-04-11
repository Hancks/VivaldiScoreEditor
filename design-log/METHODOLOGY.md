# Design-Log Methodology - Guida Completa

> Questo file contiene la metodologia dettagliata. Per le istruzioni essenziali, vedi `CLAUDE.md` nella root.

## Overview

Questo progetto usa la **Design-Log Methodology** (ispirata a [Wix Engineering](https://www.wix.engineering/post/why-i-stop-prompting-and-start-logging-the-design-log-methodology)). Claude non è solo un coder, ma un **partner nel processo architetturale**.

## Core Principles

1. **Design Before You Implement**: Un design log deve essere creato e approvato PRIMA di scrivere codice.

2. **Immutable History**: Una volta iniziata l'implementazione, la sezione "Design" è FROZEN. Le modifiche vanno in "Implementation Results".

3. **The Socratic Method**: Per informazioni mancanti, FAI DOMANDE nel design log. Non assumere, chiedi.

4. **Traceable Implementation**: Se devii dal piano, documenta PERCHÉ in "Implementation Results".

---

## Struttura Completa delle Cartelle

```
./design-log/
├── PROJECT.md                          # Overview del progetto (stabile)
├── PROGRESS.md                         # Indice leggero → punta ai file sotto
├── TODO.md                             # Cose da fare (feature, miglioramenti)
├── TO_FIX.md                           # Bug da fixare
├── TO_TEST.md                          # Da testare su device
├── DONE.md                             # Lavoro completato (recente)
├── FIXED.md                            # Bug risolti (recente)
├── progress.old.md                     # Archivio sessioni vecchie
├── METHODOLOGY.md                      # Questo file
├── BEHAVIORS.md                        # Regole comportamentali per Claude
├── LEARNED.md                          # Competenze tecniche riutilizzabili
├── sessions/                           # Log delle sessioni
│   ├── latest.md                       # Ultima sessione (quick access)
│   └── YYYY-MM-DD-HH-MM.md            # Archivio sessioni
├── issues/                             # Issue tracking
│   ├── _INDEX.md                       # Indice issue
│   └── {TYPE}-{NNN}-{slug}.md         # Singole issue
└── YYYY-MM-DD-feature-name.md          # Design decisions (immutabili dopo approvazione)
```

**Nota sulla struttura progress:**
- `PROGRESS.md` è solo un indice con link e stato rapido
- Il lavoro è suddiviso in file separati per tipo (TODO, TO_FIX, TO_TEST, DONE, FIXED)
- `progress.old.md` contiene l'archivio delle sessioni pre-marzo 2026

**Nota sui design log attivi:** I file `YYYY-MM-DD-feature-name.md` con Status diverso da "Implemented" sono design in corso e vanno letti durante `/startsession` per mantenere contesto sulle decisioni architetturali in progress.

---

## Template: PROJECT.md

```markdown
# [Project Name]

## Vision
What is this project? What problem does it solve? One paragraph max.

## Tech Stack
- Language: [e.g., TypeScript, Python]
- Framework: [e.g., Next.js, FastAPI]
- Database: [e.g., PostgreSQL, MongoDB]
- Other: [e.g., Redis, Docker]

## Architecture Overview
Brief description of how the system is organized.

## Key Directories
/src          - Main source code
/tests        - Test files
/docs         - Documentation

## Conventions
- Naming: [e.g., camelCase for functions, PascalCase for classes]
- Testing: [e.g., Jest, pytest]
- Git: [e.g., conventional commits]

## Getting Started
How to run the project locally (brief commands).
```

---

## Template: PROGRESS.md

```markdown
# Project Progress

> Last updated: YYYY-MM-DD HH:MM
> Last session: [link to session file]

---

## DONE

### [Date] - [Feature/Task Name]
**What:** Brief description
**How:** Technical approach, key decisions
**Files:** List of files created/modified
**Design log:** [Link if exists]
**Notes:** Gotchas, learnings

---

## TODO

### High Priority

#### [Task Name]
**What:** What needs to be done
**Why:** Why it's important
**How (proposed):** Initial thoughts
**Design log:** Link or "Needs design"

### Medium Priority
...

### Low Priority / Ideas
...

---

## Open Questions
- [ ] Question 1
- [ ] Question 2

---

## Quick Links
- [PROJECT.md](./PROJECT.md)
- [Latest session](./sessions/latest.md)
- [Issues](./issues/_INDEX.md)
```

---

## Template: Design Log

Per nuove feature o modifiche significative, crea `YYYY-MM-DD-feature-name.md`:

```markdown
# [Feature/Decision Name]

> Created: YYYY-MM-DD
> Status: Draft | Approved | Implementing | Implemented
> Author: [Human/Claude]

## Background
Context and motivation. Why this is needed now.

## Problem
Clear statement of what needs to be solved.

## Questions and Answers

> Use Socratic method: Ask questions, don't guess!

**Q:** [Question]
**A:** [Answer - keep both permanently]

## Design

> This section is FROZEN once implementation begins.

### Overview
High-level approach.

### Detailed Design
- Include specific file paths
- Include type signatures
- Include validation rules

## Implementation Plan

- [ ] Step 1: [description]
- [ ] Step 2: [description]
- [ ] Step 3: [description]

## Trade-offs

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| A | ... | ... | Chosen/Rejected |
| B | ... | ... | Chosen/Rejected |

**Rationale:** [Why this approach]

## Implementation Results

> Add notes here DURING implementation. Never modify Design section.

### [Date] - Notes
- Deviated from plan because: [reason]
- Discovered issue: [description]
- Actual files created: [list]
```

---

## Template: Session Log

Salva in `sessions/YYYY-MM-DD-HH-MM.md`:

```markdown
# Session Log: YYYY-MM-DD HH:MM

## Session Summary
One paragraph: goal and achievement.

---

## CRITICAL SECTIONS - What Compaction Loses

### Active Skills & Methodologies
1. **[Skill Name]**
   - Purpose: [what it does]
   - Key principles: [2-3 bullet points]
   - Current usage: [how we're applying it]

### Procedure State
**[Procedure Name]** (X/Y completed):
- [x] Step 1
- [x] Step 2
- [ ] Step 3 <- CURRENT STEP
- [ ] Step 4

### What We Tried That Didn't Work
- **[Attempt]**: [Why it failed] -> [What we did instead]

### User Preferences Discovered
- [Preference]: [Context/example]

---

## Context Snapshot

### Currently Working On
- Feature/task: [current task]
- File(s): [files being edited]
- Branch: [git branch]

### Key Decisions Made This Session
1. **[Decision]**: [WHY not just what]

### Problems Encountered & Resolutions
- **[Problem]**: [Resolution or status]

---

## Handoff Notes

### Immediate Next Steps
1. [Specific actionable step]

### Blockers / Waiting On
- [ ] [Blocker]

### Don't Forget
- [Critical detail]

---

## Files Modified This Session
- [path] - [description]
```

---

## Issue Tracking

### Tipi di Issue
- `bug` - Qualcosa non funziona
- `enhancement` - Miglioramento a feature esistente
- `review` - Qualcosa da verificare

### Severity (bug) / Priority (altri)
- Bug: critical -> major -> minor -> trivial
- Enhancement/Review: high -> medium -> low

### Status
- `in-progress` - In lavorazione
- `blocked` - Bloccato (specificare perché)
- `closed` - Completato (documentare soluzione)
- `rejected` - Non si fa (specificare perché)

### Template Issue

```markdown
# [{TYPE}-{NNN}] {Title}

> Type: bug | enhancement | review
> Severity/Priority: [level]
> Status: in-progress | blocked | closed | rejected
> Created: YYYY-MM-DD

## Description
[description]

## Context
Discovered during: [session/context]

## Steps to Reproduce (for bugs)
1. ...
2. ...

**Expected:**
**Actual:**

## Solution

### Approach
[how it was solved]

### Changes Made
[files modified]

### Related
[links to design logs, commits]
```

---

## Quality Checklists

### PROJECT.md
- [ ] Vision clear in one paragraph
- [ ] Tech stack complete
- [ ] Key directories explained
- [ ] Conventions documented

### PROGRESS.md
- [ ] "Last updated" current
- [ ] Completed work in DONE with How/Files
- [ ] TODOs have proposed approaches
- [ ] Priorities clear
- [ ] Reference to latest session

### Design Logs
- [ ] Background explains WHY
- [ ] Problem specific and clear
- [ ] Q&A has actual questions/answers
- [ ] Design includes file paths
- [ ] Implementation Plan has checkable items
- [ ] Status accurate

### Session Logs
- [ ] Summary captures goal/achievement
- [ ] Key decisions documented with reasoning
- [ ] Next steps specific and actionable
- [ ] Files modified listed

---

## Project Discovery Mode

Quando `/startsession` trova PROJECT.md vuoto, si attiva il **Project Discovery Mode** che interrompe il flusso normale.

### Criterio "PROJECT.md vuoto"
- Non esiste
- Esiste ma ha solo titolo, placeholder, template non compilato
- Nessuna riga con contenuto informativo reale sul progetto

### Due scenari

**Progetto esistente** (ci sono file sorgente, package manager, struttura riconoscibile):
1. Analisi profonda: struttura, stack, architettura, codice core, config, test, docs
2. Per progetti grandi (>50 file): parallelizzare con Agent
3. Presentare deduzioni (natura, scopo, target, stack, architettura, stato)
4. Chiedere conferma/correzioni
5. Dopo conferma: popolare PROJECT.md e PROGRESS.md

**Progetto nuovo** (solo file design-log nella directory):
1. Domande guidate: scopo, target, funzionalità, tech, UI/UX, vincoli
2. Domande contestuali aggiuntive in base alle risposte
3. Dopo risposte e conferma: popolare PROJECT.md e PROGRESS.md

Dopo la discovery, il flusso normale di /startsession riprende.

Dettagli completi: vedi `.claude/commands/startsession.md`

---

## Workflow Completo

### Ricevendo un Task

1. Il task è in PROGRESS.md TODO?
   - Sì: verifica se esiste design log
   - No: aggiungilo alla priorità appropriata

2. Serve un design log?
   - Cambio piccolo (< 3 file): procedi direttamente
   - Cambio significativo: crea design log PRIMA

3. Per design logs:
   - Crea draft con Background, Problem, Questions
   - FAI domande (Socratic method)
   - Aspetta risposte utente
   - Completa Design
   - Ottieni approvazione
   - POI implementa

### Dopo Ogni Task

1. File di tracking:
   - Se era un TODO → muovi da `TODO.md` a `DONE.md`
   - Se era un bug → muovi da `TO_FIX.md` a `FIXED.md`
   - Se serve test su device → aggiungi a `TO_TEST.md`
   - Aggiorna `PROGRESS.md` (stato rapido, contatori)
   - Aggiorna timestamp

2. Design log (se esiste):
   - Spunta item completati in Implementation Plan
   - Aggiungi note in Implementation Results
   - Aggiorna Status

3. Session log (se necessario):
   - Sessione lunga (15+ scambi)?
   - Milestone importante completata?
   - Stai per cambiare contesto?

---

## LEARNED.md — Cosa scrivere e cosa NO

LEARNED.md contiene **competenze tecniche e metodologiche riutilizzabili** — skill che sarebbero utili anche in un progetto diverso.

### ✅ VA in LEARNED
- Pattern SwiftUI generici (es. "Color.clear non riceve drop events")
- Tecniche audio AVFoundation (es. "un solo tap per bus")
- Gotcha di Xcode/Swift/iOS (es. "UIDevice.current.name = iPhone da iOS 16")
- Skill di music programming (es. "staffPosition da MIDI: formula")
- Pattern architetturali (es. "NSLock per stato cross-thread")

### ❌ NON VA in LEARNED
- Regole specifiche del prodotto ("preset Advanced ha priorità su counting")
- Decisioni di business ("il bordone slider appare solo se attivo")
- Comportamento specifico di una feature ("ear training bypassa il wizard")
- Valori hardcoded del progetto ("sfondo steampunk = LinearGradient 3 colori...")
- Preferenze utente/UX specifiche ("l'utente vuole tab, non dropdown")
- Meta su Claude/metodologia (quelle vanno in BEHAVIORS.md)

**Test rapido:** "Questa informazione sarebbe utile se stessi costruendo un'app completamente diversa?" Se sì → LEARNED. Se no → è nel codice o nel design log.

---

## Il Principio Fondamentale

**"Non fidarti di Claude. Verifica."**

Ogni comando ha:
1. **Step OBBLIGATORI** - ORDINI, non suggerimenti
2. **Output VISIBILE** - checklist che l'utente vede
3. **Checkpoint** - punti dove Claude si FERMA e aspetta
