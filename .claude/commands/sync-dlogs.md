# Sync Design Logs Command

Safety net per sincronizzare i file quando Claude dimentica di aggiornarli.

## Quando usarlo

- Dopo che Claude completa un task ma non aggiorna i file
- Quando non sei sicuro se i file sono sincronizzati
- Prima di /savesession (come double-check)
- Dopo modifiche significative

---

## STEP OBBLIGATORI

### STEP 1: Analizza conversazione recente

Identifica:
- Task completati
- Decisioni prese
- File modificati
- Design log creati/aggiornati

**OUTPUT OBBLIGATORIO:**
```
🔍 Analisi conversazione:
- Task completati: [lista]
- Decisioni prese: [lista]
- File modificati: [lista]
- Design log coinvolti: [lista o "nessuno"]
```

---

### STEP 2: Verifica PROGRESS.md

Controlla se è aggiornato.

**Checklist da verificare:**
- [ ] "Last updated" è corrente?
- [ ] Task completati sono in DONE?
- [ ] DONE ha What/How/Files/Notes?
- [ ] Nuovi TODO sono stati aggiunti?

**OUTPUT OBBLIGATORIO:**
```
📊 PROGRESS.md:
✅ Last updated corrente
✅ Task in DONE
❌ Manca What/How/Files → AGGIORNATO
✅ TODO aggiornato
```

Se qualcosa manca → AGGIORNALO e mostra ❌ → AGGIORNATO

---

### STEP 3: Verifica Design Log (se esiste)

**Checklist da verificare:**
- [ ] Implementation Results aggiornato?
- [ ] Implementation Plan spuntato?
- [ ] Status corretto?

**OUTPUT OBBLIGATORIO:**
```
📝 Design log [nome]:
✅ Implementation Results aggiornato
❌ Implementation Plan non spuntato → AGGIORNATO
✅ Status: Implementing
```

Se non c'è design log:
```
📝 Design log: nessuno coinvolto
```

---

### STEP 4: Verifica Session Log (se necessario)

**Checklist da verificare:**
- [ ] Sessione lunga (15+ scambi)?
- [ ] Nuove skill/procedure da documentare?
- [ ] Tentativi falliti da registrare?
- [ ] Preferenze utente scoperte?

**OUTPUT OBBLIGATORIO:**
```
📅 Session log:
⚠️ Sessione lunga (20+ scambi) - considera /savesession
✅ Nessun tentativo fallito da registrare
✅ Nessuna preferenza nuova
```

---

### STEP 5: Riepilogo finale

**OUTPUT OBBLIGATORIO:**
```
🔄 SYNC COMPLETATO

Aggiornamenti effettuati:
✅ PROGRESS.md - [cosa aggiornato]
✅ design-log/[nome].md - [cosa aggiornato]
⏭️ Session log - già in sync

Totale: [X] file aggiornati, [Y] già in sync

⚠️ Suggerimento: [se necessario, es. "considera /savesession"]
```

Se tutto era già sincronizzato:
```
✅ TUTTO IN SYNC

Nessun aggiornamento necessario.

Ultimo aggiornamento:
- PROGRESS.md: [timestamp]
- Design log attivo: [nome o "nessuno"]
- Ultima sessione: [timestamp]
```

---

## Checklist di verifica per l'utente

Dopo che Claude esegue `/sync-dlogs`, verifica:

- [ ] Ha analizzato la conversazione?
- [ ] Ha verificato PROGRESS.md?
- [ ] Ha verificato design log (se esiste)?
- [ ] Ha considerato session log?
- [ ] Ha mostrato riepilogo con ✅/❌?

Se manca qualcosa, Claude non ha seguito il comando correttamente.
