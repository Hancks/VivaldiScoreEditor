# Add Task Command

FORZA l'uso della metodologia Design-Log per ogni nuovo task.

## Perché questo comando esiste

Claude ha ammesso: "Se non me lo avessi chiesto, non avrei seguito la metodologia."

Questo comando FORZA il comportamento corretto. Non è opzionale.

## Usage

```
/add-task "descrizione del task"
```

Esempio:
```
/add-task "Aggiungere autenticazione JWT"
```

---

## STEP OBBLIGATORI

### STEP 1: Verifica se esiste già

Cerca in PROGRESS.md se il task è già presente.

**OUTPUT OBBLIGATORIO:**
```
🔍 Verifica task esistente:
✅ Cercato in PROGRESS.md TODO
📋 Risultato: [NON TROVATO | TROVATO in sezione [X]]
```

Se TROVATO, chiedi:
```
Questo task sembra già esistere in PROGRESS.md.
Vuoi:
A) Lavorare su quello esistente
B) Crearne uno nuovo comunque
```

---

### STEP 2: Valuta complessità

**OUTPUT OBBLIGATORIO:**
```
📊 Valutazione complessità:
- File coinvolti (stima): [numero]
- Tipo: [semplice | significativo]
- Richiede design log: [SÌ | NO]
```

**Criteri:**
- **Semplice** (NO design log): < 3 file, fix ovvio, nessuna decisione architetturale
- **Significativo** (SÌ design log): >= 3 file, nuova feature, decisioni da prendere

Se **NO** → salta a STEP 9 (implementa direttamente)
Se **SÌ** → continua con STEP 3

---

### STEP 3: Crea design log

Crea file: `design-log/YYYY-MM-DD-[slug].md`

**OUTPUT OBBLIGATORIO:**
```
📝 Design log creato:
✅ File: design-log/[nome-file].md
```

---

### STEP 4: Scrivi Background e Problem

Compila le sezioni iniziali del design log.

**OUTPUT OBBLIGATORIO:**
```
📄 Sezioni compilate:
✅ Background - [1-2 frasi di riepilogo]
✅ Problem - [1-2 frasi di riepilogo]
```

---

### STEP 5: Scrivi domande (Metodo Socratico)

NON assumere. Fai DOMANDE su tutto ciò che non è chiaro.

**OUTPUT OBBLIGATORIO:**
```
❓ Domande per te:

Q1: [domanda specifica]
Q2: [domanda specifica]
Q3: [domanda specifica]
...
```

Minimo 2 domande. Se non ci sono domande, spiega perché:
```
❓ Nessuna domanda: [spiegazione del perché tutto è chiaro]
```

---

### 🛑 STEP 6: FERMATI - Aspetta risposte

**OUTPUT OBBLIGATORIO:**
```
🛑 CHECKPOINT

Attendo le tue risposte alle domande prima di procedere.
Non procederò finché non rispondi.
```

**NON procedere finché l'utente non risponde.**

---

### STEP 7: Completa Design

Dopo le risposte, aggiorna il design log:
- Compila sezione Q&A con risposte
- Scrivi sezione Design
- Definisci Implementation Plan

**OUTPUT OBBLIGATORIO:**
```
📐 Design completato:
✅ Q&A compilato con risposte
✅ Sezione Design scritta
✅ Implementation Plan: [N] step definiti
```

---

### 🛑 STEP 8: FERMATI - Chiedi approvazione

**OUTPUT OBBLIGATORIO:**
```
🛑 CHECKPOINT - APPROVAZIONE RICHIESTA

Design completato: design-log/[nome-file].md

Riepilogo:
- [punto chiave 1 del design]
- [punto chiave 2 del design]
- [punto chiave 3 del design]

Implementation Plan:
1. [step 1]
2. [step 2]
3. [step 3]
...

Approvi l'implementazione? (sì/no)
```

**NON procedere finché l'utente non dice "sì", "approvato", "ok", "procedi" o simile.**

---

### STEP 9: Implementa

Solo DOPO approvazione esplicita (o se task semplice senza design log).

**OUTPUT OBBLIGATORIO (durante implementazione):**
```
🔨 Implementazione in corso:
✅ [file creato/modificato] - [cosa]
✅ [file creato/modificato] - [cosa]
...
```

---

### STEP 10: Aggiorna PROGRESS.md

Muovi/aggiungi task in DONE con What/How/Files/Notes.

**OUTPUT OBBLIGATORIO:**
```
📊 PROGRESS.md aggiornato:
✅ Task aggiunto a DONE
✅ Timestamp aggiornato: [nuovo timestamp]
```

---

### STEP 11: Aggiorna design log (se esiste)

**OUTPUT OBBLIGATORIO:**
```
📝 Design log aggiornato:
✅ Implementation Plan: tutti gli step spuntati
✅ Status: Implemented
✅ Implementation Results: note aggiunte
```

---

## Riepilogo finale

**OUTPUT OBBLIGATORIO:**
```
✅ TASK COMPLETATO

📋 Task: [descrizione]
📝 Design log: [path o "non richiesto"]
📁 File modificati: [numero]
📊 PROGRESS.md: aggiornato

Prossimo passo suggerito: [da PROGRESS.md TODO]
```

---

## Checklist di verifica per l'utente

Dopo che Claude esegue `/add-task`, verifica:

- [ ] Ha verificato se il task esisteva già?
- [ ] Ha valutato la complessità?
- [ ] (Se significativo) Ha creato un design log?
- [ ] (Se significativo) Ha fatto domande?
- [ ] (Se significativo) Si è fermato ad aspettare risposte?
- [ ] (Se significativo) Ha chiesto approvazione esplicita?
- [ ] Ha aggiornato PROGRESS.md alla fine?
- [ ] Ha aggiornato il design log alla fine (se esiste)?

Se manca qualcosa, Claude non ha seguito il comando correttamente.
