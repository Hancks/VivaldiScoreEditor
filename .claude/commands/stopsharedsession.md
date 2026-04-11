# Stop Shared Session Command

Rilascia tutti i lock creati da questa sessione e verifica la pulizia.

## Quando usarlo

- **A fine sessione** quando si è usato `/startsharedsession`
- Prima di `/savesession` se in sessione condivisa
- Quando il task parallelo è completato

---

## STEP OBBLIGATORI

### STEP 1: Elenca lock attivi

```bash
ls .locks/ 2>/dev/null || echo "Nessun lock attivo"
```

**OUTPUT OBBLIGATORIO:**
```
🔒 Lock attualmente attivi:
- .locks/[lockfile1] → [sessione che lo possiede]
- .locks/[lockfile2] → [sessione che lo possiede]
```

---

### STEP 2: Identifica i MIEI lock

Leggi il contenuto di ogni lock e identifica quelli creati da QUESTA sessione (matching per descrizione del task).

**OUTPUT OBBLIGATORIO:**
```
🔓 Lock da rilasciare (miei):
- .locks/[lockfile1] → [file1]
- .locks/[lockfile2] → [file2]

🔒 Lock di altre sessioni (NON toccare):
- .locks/[lockfile3] → [file3] (sessione: [task])
```

---

### STEP 3: Rimuovi i miei lock

```bash
rm .locks/[mio_lockfile1]
rm .locks/[mio_lockfile2]
```

**Se la directory `.locks/` è vuota dopo la rimozione:**
```bash
rmdir .locks/ 2>/dev/null
```

**OUTPUT OBBLIGATORIO:**
```
🔓 Lock rilasciati:
✅ [file1] — libero
✅ [file2] — libero

📊 Lock rimanenti di altre sessioni: [N]
```

---

### STEP 4: Conferma pulizia

```
✅ SESSIONE CONDIVISA CHIUSA

🔓 [N] lock rilasciati
🔒 [M] lock di altre sessioni ancora attivi
📂 Directory .locks/: [vuota / contiene M lock]

La sessione parallela è terminata. I file sono liberi per altre sessioni.
```
