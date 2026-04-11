# 🛑 ISTRUZIONI OBBLIGATORIE PER CLAUDE

## ⚠️ PRIMA DI TUTTO

**USA `/startsession` PRIMA DI FARE QUALSIASI ALTRA COSA.**

Se l'utente non lo invoca, CHIEDILO IMMEDIATAMENTE:
> "Prima di procedere, devo eseguire /startsession per caricare il contesto. Posso?"

**NON rispondere a nessuna richiesta finché /startsession non è stato eseguito.**

---

## 🛑 PER OGNI NUOVO TASK

**USA `/add-task "descrizione"` per task significativi.**

Se l'utente chiede di implementare qualcosa di non banale, CHIEDILO:
> "Questo task richiede un design log. Posso eseguire /add-task per seguire la metodologia?"

---

## Principio Fondamentale

**"Non fidarti di Claude. Verifica."**

Ogni comando produce:
1. **Output VISIBILE** - checklist ✅/❌ che l'utente vede
2. **Checkpoint 🛑** - punti dove Claude si FERMA e aspetta

---

## Comandi Disponibili

| Comando | Quando | Obbligatorio |
|---------|--------|--------------|
| `/startsession` | Inizio sessione | 🔴 SEMPRE |
| `/add-task "desc"` | Nuovo task significativo | 🔴 Per task non banali |
| `/savesession` | Fine sessione o contesto lungo | 🟡 Consigliato |
| `/resumesession [file]` | Caricare sessione specifica | 🟢 Occasionale |
| `/sync-dlogs` | Se hai dimenticato di aggiornare | 🟢 Safety net |
| `/new-issue` | Bug/enhancement/review | 🟢 Quando serve |
| `/startsharedsession` | Sessioni parallele — lock file | 🔴 Con 2+ sessioni |
| `/stopsharedsession` | Fine sessione parallela — unlock | 🔴 Con 2+ sessioni |

---

## Regole Essenziali

### Prima di implementare
- Leggi i file che modificherai
- Per task significativi: usa `/add-task`

### Dopo ogni task
- Aggiorna `PROGRESS.md` (TODO → DONE)
- Aggiorna design log se esiste

### Issue Auto-Detection
Se l'utente menziona problema/bug/miglioramento:
> "Vuoi che crei un'issue per questo?"

---

## Struttura design-log/

```
design-log/
├── PROJECT.md          # Cos'è il progetto
├── PROGRESS.md         # Done/Todo (SEMPRE aggiornato)
├── METHODOLOGY.md      # Come lavorare (dettagli)
├── BEHAVIORS.md        # Regole comportamentali
├── LEARNED.md          # Memoria di apprendimento
├── sessions/
│   └── latest.md       # Ultima sessione
├── issues/
│   └── _INDEX.md       # Indice issue
└── YYYY-MM-DD-*.md     # Design decisions
```

---

## Metodologia Completa

Per dettagli su template e workflow, leggi:
`design-log/METHODOLOGY.md`

---

## Checklist per l'utente

### Dopo /startsession, Claude deve aver mostrato:
- [ ] Checklist struttura (✅/❌)
- [ ] Numero righe lette per ogni file
- [ ] Riepilogo che dimostra comprensione
- [ ] Si è fermato ad aspettare conferma

### Dopo /add-task, Claude deve aver:
- [ ] Verificato se task esisteva
- [ ] Valutato complessità
- [ ] (Se significativo) Creato design log
- [ ] (Se significativo) Fatto domande
- [ ] (Se significativo) Aspettato risposte
- [ ] (Se significativo) Chiesto approvazione
- [ ] Aggiornato PROGRESS.md

**Se manca qualcosa, Claude non ha seguito le istruzioni.**
