# Save Session Command

Salva il contesto della sessione corrente e sincronizza TUTTI i documenti della metodologia.

## Quando usarlo

- Conversazione lunga (15+ scambi)
- Prima di terminare la sessione
- Prima di cambiare contesto
- Dopo milestone importante
- Dopo debugging complesso

---

## STEP OBBLIGATORI

### STEP 1: Ri-leggi METHODOLOGY.md

Rileggi `design-log/METHODOLOGY.md` per rinfrescare la memoria su cosa devi fare.

**OUTPUT OBBLIGATORIO:**
```
📖 METHODOLOGY.md riletto
```

---

### STEP 2: Sync documenti (logica sync-dlogs)

Analizza la conversazione e sincronizza TUTTI i documenti.

#### 2a: Analizza conversazione

Identifica: task completati, decisioni prese, file modificati, design log coinvolti.

#### 2b: Verifica e aggiorna PROGRESS.md

Checklist:
- [ ] "Last updated" corrente?
- [ ] Task completati sono in DONE con What/How/Files/Notes?
- [ ] Nuovi TODO aggiunti se necessario?

#### 2c: Verifica e aggiorna Design Log (se esiste)

Checklist:
- [ ] Implementation Results aggiornato?
- [ ] Implementation Plan spuntato?
- [ ] Status corretto?

#### 2d: Verifica e aggiorna issues/_INDEX.md (se necessario)

Checklist:
- [ ] Nuove issue create durante la sessione?
- [ ] Status issue aggiornati?

**OUTPUT OBBLIGATORIO:**
```
🔄 Sync documenti:
✅ PROGRESS.md - [aggiornato | gia' in sync]
✅ Design log [nome] - [aggiornato | gia' in sync | nessuno]
✅ Issues - [aggiornato | gia' in sync]
```

Se qualcosa era fuori sync, mostra cosa e' stato corretto:
```
❌ PROGRESS.md - mancava DONE per [task] → AGGIORNATO
```

---

### STEP 3: Aggiorna LEARNED.md

Rifletti sulla sessione e aggiungi nuovi apprendimenti a `design-log/LEARNED.md`.

Chiediti:
- Ho scoperto un pattern tecnico riutilizzabile?
- Ho fatto un errore che non devo ripetere?
- Ho scoperto una preferenza dell'utente?
- Ho trovato una soluzione a un problema che potrebbe ripresentarsi?

Se ci sono nuovi apprendimenti, aggiungili alla sezione appropriata.
Se non ci sono, non modificare il file.

**OUTPUT OBBLIGATORIO:**
```
🧠 LEARNED.md: [N nuovi apprendimenti aggiunti | nessun nuovo apprendimento]
```

Se aggiunti, elencali brevemente:
```
🧠 LEARNED.md: 2 nuovi apprendimenti aggiunti
  - Pattern: [breve]
  - Errore: [breve]
```

---

### STEP 4: Crea session log

Genera timestamp formato `YYYY-MM-DD-HH-MM`.
Crea file `design-log/sessions/[timestamp].md` con la struttura completa (vedi METHODOLOGY.md).

**OUTPUT OBBLIGATORIO:**
```
📝 Session log creato:
✅ File: design-log/sessions/[timestamp].md
```

---

### STEP 5: Aggiorna latest.md (symlink)

Crea symlink relativo al nuovo file sessione.

```bash
cd design-log/sessions
rm -f latest.md
ln -s [timestamp].md latest.md
```

**OUTPUT OBBLIGATORIO:**
```
🔗 latest.md → [timestamp].md
```

---

### STEP 6: Riepilogo finale

**OUTPUT OBBLIGATORIO:**
```
✅ SESSIONE SALVATA

📁 Session log: design-log/sessions/[timestamp].md
🔄 Sync: [N] documenti aggiornati, [M] gia' in sync
🧠 Learned: [N] nuovi apprendimenti
🔗 Symlink: latest.md → [timestamp].md

Contenuto salvato:
- Active skills: [lista breve]
- Next steps: [primo step]

Per riprendere, usa /startsession (leggera' latest.md e LEARNED.md automaticamente).
```

---

## Template Session Log (Riferimento)

Il file deve contenere queste sezioni (vedi METHODOLOGY.md per dettagli):

1. **Session Summary** - Cosa e' stato fatto
2. **CRITICAL SECTIONS**:
   - Active Skills & Methodologies
   - Procedure State
   - What We Tried That Didn't Work
   - User Preferences Discovered
3. **Context Snapshot**:
   - Currently Working On
   - Key Decisions Made
   - Problems Encountered
4. **Handoff Notes**:
   - Immediate Next Steps
   - Blockers / Waiting On
   - Don't Forget
5. **Files Modified This Session**

---

## Checklist di verifica per l'utente

Dopo che Claude esegue `/savesession`, verifica:

- [ ] Ha riletto METHODOLOGY.md?
- [ ] Ha sincronizzato PROGRESS.md?
- [ ] Ha sincronizzato design log (se esiste)?
- [ ] Ha sincronizzato issue (se necessario)?
- [ ] Ha aggiornato LEARNED.md (o detto "nessun apprendimento")?
- [ ] Ha creato il session log con tutte le sezioni?
- [ ] Ha creato symlink latest.md (non copia)?
- [ ] Ha mostrato riepilogo finale?

Se manca qualcosa, Claude non ha seguito il comando correttamente.
