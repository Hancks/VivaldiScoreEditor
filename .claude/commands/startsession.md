# Start Session Command

Carica il contesto del progetto all'inizio di ogni sessione.

## QUESTO COMANDO È OBBLIGATORIO

L'utente DEVE invocare `/startsession` all'inizio di ogni sessione.
Se non lo fa, Claude DEVE chiederlo prima di fare qualsiasi altra cosa.

---

## STEP OBBLIGATORI

### STEP 1: Verifica struttura COMPLETA

Verifica che esistano TUTTE queste directory e file.
Se qualcosa manca, CREALO.

**Checklist da verificare:**
- `design-log/`
- `design-log/sessions/`
- `design-log/issues/`
- `design-log/PROJECT.md`
- `design-log/PROGRESS.md`
- `design-log/METHODOLOGY.md`
- `design-log/BEHAVIORS.md` ← CRITICO: regole comportamentali
- `design-log/LEARNED.md` ← memoria di apprendimento
- `design-log/sessions/latest.md`
- `design-log/issues/_INDEX.md`

**OUTPUT OBBLIGATORIO:**
```
📁 Verifica struttura:
✅ design-log/
✅ design-log/sessions/
✅ design-log/issues/
✅ PROJECT.md
✅ PROGRESS.md
✅ METHODOLOGY.md
✅ BEHAVIORS.md
✅ LEARNED.md
✅ sessions/latest.md
✅ issues/_INDEX.md
```

Se qualcosa manca, mostra:
```
❌ [file/cartella] → CREATO
```

---

### STEP 2: Leggi BEHAVIORS.md + LEARNED.md

Leggi SEMPRE questi due file per primi:

1. `design-log/BEHAVIORS.md` - ⚠️ PRIMA DI TUTTO: regole comportamentali
2. `design-log/LEARNED.md` - Memoria di apprendimento accumulata

**OUTPUT OBBLIGATORIO:**
```
📖 File base letti:
✅ BEHAVIORS.md ([N] righe) ← REGOLE COMPORTAMENTALI
✅ LEARNED.md ([N] righe) ← MEMORIA APPRENDIMENTO
```

---

### STEP 2.5: 🔍 GATE - Leggi PROJECT.md e valuta se vuoto

Leggi `design-log/PROJECT.md` e VALUTA se contiene informazioni reali sul progetto.

**PROJECT.md è considerato VUOTO se:**
- Non esiste
- Esiste ma ha 0 righe di contenuto
- Esiste ma contiene SOLO: titolo (`# ...`), placeholder (`[...]`), template non compilato, commenti, righe vuote
- Non ci sono almeno 2 righe con contenuto informativo reale che descrivano il progetto

**OUTPUT OBBLIGATORIO:**
```
🔍 Valutazione PROJECT.md:
📄 Stato: [POPOLATO | VUOTO]
```

**Se POPOLATO** → vai a STEP 3 (flusso normale)
**Se VUOTO** → vai a STEP P1 (Project Discovery Mode) ⚠️ IL FLUSSO NORMALE SI INTERROMPE

---

## 🔍 PROJECT DISCOVERY MODE

> Questo blocco si attiva SOLO se PROJECT.md è vuoto.
> Il flusso normale di /startsession è INTERROTTO fino al completamento.

### STEP P1: Analizza il repository

Esamina la directory del progetto per capire se esiste già codice/contenuto.

**Criteri per "progetto esistente":**
- Ci sono file sorgente (*.py, *.js, *.ts, *.swift, *.go, *.rs, *.java, *.c, *.cpp, etc.)
- Ci sono file di progetto (package.json, Cargo.toml, requirements.txt, Makefile, *.xcodeproj, etc.)
- Ci sono asset, documenti, configurazioni significative
- Qualsiasi struttura di progetto riconoscibile OLTRE ai file del design-log system

**Criteri per "progetto nuovo":**
- La directory contiene SOLO i file del design-log system (.claude/, design-log/, CLAUDE.md)
- Nessun file sorgente, nessuna struttura di progetto

**OUTPUT OBBLIGATORIO:**
```
🔍 Analisi repository:
📂 Tipo: [PROGETTO ESISTENTE | PROGETTO NUOVO]
📄 Evidenze: [elenco breve di cosa è stato trovato o "solo file design-log"]
```

**Se PROGETTO ESISTENTE** → vai a STEP E1
**Se PROGETTO NUOVO** → vai a STEP N1

---

### Ramo A: PROGETTO ESISTENTE

#### STEP E1: Analisi profonda

Claude deve raggiungere una comprensione sufficiente a gestire il progetto IN AUTONOMIA.

**Analizzare IN PROFONDITÀ:**

1. **Struttura directory** - layout cartelle, organizzazione moduli
2. **Stack tecnologico** - linguaggi, framework, dipendenze (da package manager, config files)
3. **Architettura** - pattern (MVC, MVVM, microservizi, etc.), entry point, flusso dati
4. **Codice sorgente** - leggere i file principali, capire la logica core, i modelli dati, le API
5. **Configurazioni** - build system, CI/CD, env, database
6. **Test** - framework test, copertura, come eseguirli
7. **Documentazione esistente** - README, commenti, doc inline

**Se il progetto è grande (>50 file sorgente):**
Usare Agent per parallelizzare l'analisi in sub-task:
- Agent 1: struttura + dipendenze + config
- Agent 2: architettura + codice core + modelli dati
- Agent 3: test + docs + build system

**OUTPUT OBBLIGATORIO:**
```
🔬 Analisi profonda completata:

📂 **Struttura**: [descrizione layout]
🛠️ **Stack**: [linguaggi, framework, dipendenze principali]
🏗️ **Architettura**: [pattern, moduli principali, flusso dati]
📝 **Codice core**: [file principali e loro ruolo]
⚙️ **Config/Build**: [come si builda, si esegue, si deploya]
🧪 **Test**: [framework, come eseguirli]
📖 **Docs**: [documentazione trovata]
```

---

#### STEP E2: Presenta deduzioni

Mostra all'utente cosa ha dedotto e chiedi conferma.

**OUTPUT OBBLIGATORIO:**
```
🧠 Ecco cosa ho dedotto dal progetto:

📂 **Nome progetto**: [dedotto o da confermare]
🎯 **Scopo**: [cosa fa il progetto, che problema risolve]
👥 **Target**: [a chi è destinato]
🛠️ **Stack tecnologico**: [elenco completo]
🏗️ **Architettura**: [descrizione pattern e organizzazione]
📋 **Funzionalità principali**:
   1. [feature 1]
   2. [feature 2]
   3. [feature N]

📊 **Stato attuale del progetto**:
   - [cosa sembra completato]
   - [cosa sembra in corso]
   - [cosa sembra mancante o da fare]

❓ **Domande/dubbi**:
   - [cosa non è chiaro dall'analisi]
   - [dove servono chiarimenti]
```

---

#### 🛑 STEP E3: FERMATI - Chiedi conferma

**OUTPUT OBBLIGATORIO:**
```
🛑 CHECKPOINT - CONFERMA DEDUZIONI

Le deduzioni sopra sono corrette? Correggimi dove sbaglio.
In particolare conferma:
- Scopo del progetto
- Target
- Funzionalità principali
- Stato attuale

Eventuali correzioni o integrazioni?
```

**NON procedere finché l'utente non conferma o corregge.**

---

#### STEP E4: Popola file

Dopo conferma, scrivi:
- **PROJECT.md** - compilato con tutte le informazioni confermate
- **PROGRESS.md** - con DONE (lavoro già fatto dedotto) e TODO (cose da fare dedotte), solo se confermati

**OUTPUT OBBLIGATORIO:**
```
📝 File aggiornati:
✅ PROJECT.md - compilato ([N] righe)
✅ PROGRESS.md - aggiornato con [N] DONE e [N] TODO dedotti
```

**→ Vai a STEP 3 (riprendi flusso normale)**

---

### Ramo B: PROGETTO NUOVO

#### STEP N1: Domande guidate

Claude pone domande adattive per definire il progetto. Set minimo, ma Claude DEVE aggiungere domande contestuali in base al tipo di progetto che emerge.

**OUTPUT OBBLIGATORIO:**
```
🆕 Nuovo progetto! Ho bisogno di alcune informazioni per partire.

❓ Domande:

1. **Scopo**: Cosa deve fare questo progetto? Che problema risolve?
2. **Target**: A chi è destinato? (utenti finali, sviluppatori, team interno, etc.)
3. **Funzionalità principali**: Quali sono le feature core che vuoi?
4. **Tecnologia**: Hai preferenze su linguaggio/framework? Vincoli tecnici?
5. **Interfaccia**: Serve un'interfaccia utente? Di che tipo? (web, mobile, CLI, desktop, nessuna)
6. **Vincoli**: Deadline, dipendenze esterne, integrazioni con altri sistemi?
```

Claude DEVE aggiungere domande extra se il contesto lo richiede. Esempi:
- Se l'utente menziona "app mobile" → domande su piattaforma (iOS/Android/cross), design system
- Se menziona "API" → domande su autenticazione, rate limiting, documentazione
- Se menziona "gioco" → domande su genere, piattaforma, engine
- Se non è un progetto software → domande sulla natura specifica (ricerca, documentazione, design, etc.)

---

#### 🛑 STEP N2: FERMATI - Aspetta risposte

**OUTPUT OBBLIGATORIO:**
```
🛑 CHECKPOINT

Attendo le tue risposte. Rispondi come preferisci - anche in forma libera,
non devi seguire la numerazione.
```

**NON procedere finché l'utente non risponde.**

---

#### STEP N3: Popola file

Dopo le risposte, Claude:
1. Riassume ciò che ha capito e chiede conferma rapida
2. Dopo conferma, scrive:
   - **PROJECT.md** - compilato con tutte le informazioni
   - **PROGRESS.md** - con TODO iniziale basato sulle funzionalità descritte

**OUTPUT OBBLIGATORIO:**
```
📝 File creati:
✅ PROJECT.md - compilato ([N] righe)
✅ PROGRESS.md - piano iniziale con [N] TODO
```

**→ Vai a STEP 3 (riprendi flusso normale)**

---

## FLUSSO NORMALE (continua dopo STEP 2.5 o dopo Discovery)

### STEP 3: Leggi file rimanenti

Leggi i file restanti nell'ordine specificato:

1. `design-log/PROJECT.md` - (ri-leggi se appena popolato dalla discovery)
2. `design-log/PROGRESS.md` - Sapere Done e Todo
3. `design-log/sessions/latest.md` - Contesto ultima sessione
4. `design-log/METHODOLOGY.md` - Come lavorare
5. `design-log/issues/_INDEX.md` - Issue aperte

**OUTPUT OBBLIGATORIO:**
```
📖 File letti:
✅ PROJECT.md ([N] righe)
✅ PROGRESS.md ([N] righe)
✅ sessions/latest.md ([N] righe)
✅ METHODOLOGY.md ([N] righe)
✅ issues/_INDEX.md ([N] righe)
```

---

### STEP 4: Genera riepilogo

Mostra all'utente che hai CAPITO il contesto.

**OUTPUT OBBLIGATORIO:**
```
🧠 **REGOLE COMPORTAMENTALI** (da BEHAVIORS.md):
- [regola 1 critica]
- [regola 2 critica]
- [regola 3 critica]

💡 **APPRENDIMENTI CHIAVE** (da LEARNED.md):
- [apprendimento 1 rilevante]
- [apprendimento 2 rilevante]
- [apprendimento 3 rilevante]

📂 **Progetto**: [nome e breve descrizione da PROJECT.md]
🛠️ **Stack**: [tecnologie da PROJECT.md]

📊 **Stato attuale**:
- Ultima sessione: [data da latest.md]
- Ultimo lavoro: [cosa da latest.md]
- Issue aperte: [numero da _INDEX.md]
- Prossima priorità: [primo item 🔴 da PROGRESS.md TODO]

📝 **Dall'ultima sessione**:
- [punto chiave 1 da latest.md Handoff Notes]
- [punto chiave 2 da latest.md Handoff Notes]

🎯 **Prossimo passo suggerito**: [azione specifica basata su TODO e Handoff]
```

---

### 🛑 STEP 5: FERMATI - Aspetta conferma

**OUTPUT OBBLIGATORIO:**
```
Procedo con [azione suggerita] o preferisci altro?
```

**NON procedere finché l'utente non conferma.**

---

## Differenza da /resumesession

| Comando | Scopo | Quando usarlo |
|---------|-------|---------------|
| `/startsession` | Carica sempre `latest.md` + auto-discovery se PROJECT vuoto | SEMPRE all'inizio |
| `/resumesession [file]` | Carica sessione specifica | Quando vuoi riprendere una sessione passata |

---

## Checklist di verifica per l'utente

Dopo che Claude esegue `/startsession`, verifica:

- [ ] Ha mostrato la checklist della struttura?
- [ ] Ha letto BEHAVIORS.md e LEARNED.md?
- [ ] Ha valutato se PROJECT.md è vuoto o popolato?
- [ ] (Se vuoto) Ha analizzato il repo o fatto domande per nuovo progetto?
- [ ] (Se vuoto) Si è fermato a chiedere conferma delle deduzioni/risposte?
- [ ] (Se vuoto) Ha popolato PROJECT.md e PROGRESS.md dopo conferma?
- [ ] Ha mostrato quante righe ha letto per ogni file?
- [ ] Ha mostrato un riepilogo che dimostra comprensione?
- [ ] Si è fermato ad aspettare conferma finale?

Se manca qualcosa, Claude non ha seguito il comando correttamente.
