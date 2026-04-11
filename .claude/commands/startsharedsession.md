# Start Shared Session Command

Dichiara i file che questa sessione intende modificare e crea lock per evitare conflitti con sessioni parallele.

## Quando usarlo

- Quando ci sono **2+ sessioni Claude in parallelo** sullo stesso repo
- **PRIMA** di modificare qualsiasi file
- Dopo `/startsession`, prima di scrivere codice

---

## STEP OBBLIGATORI

### STEP 1: Identifica i file da toccare

Analizza il task assegnato e identifica TUTTI i file che potresti modificare.

**OUTPUT OBBLIGATORIO:**
```
📋 File che intendo modificare:
1. [path/to/file1.swift]
2. [path/to/file2.swift]
...
```

---

### STEP 2: Verifica lock esistenti

Controlla se esistono file `.lock` nella directory `.locks/` del progetto per i file che vuoi toccare.

```bash
ls .locks/ 2>/dev/null || echo "Nessun lock attivo"
```

**Se trovi un lock su un file che ti serve:**
```
🔒 CONFLITTO: [file] è lockato da [sessione]
⛔ NON posso modificare questo file finché il lock non viene rimosso.
```

**FERMATI e segnala all'utente.** NON procedere.

**Se nessun conflitto:**
```
✅ Nessun conflitto — tutti i file sono liberi
```

---

### STEP 3: Crea i lock

Per ogni file da modificare, crea un file `.lock` in `.locks/`:

```bash
mkdir -p .locks
```

Il nome del lock è il path del file con `/` sostituiti da `__` (double underscore).
Esempio: `Vivaldi/Views/Trainer/ClassroomView.swift` → `.locks/Vivaldi__Views__Trainer__ClassroomView.swift.lock`

**Contenuto di ogni lock file:**
```
session: [breve descrizione del task]
date: YYYY-MM-DD HH:MM
files_locked_by_this_session:
- [path/to/file1.swift]
- [path/to/file2.swift]
```

**OUTPUT OBBLIGATORIO:**
```
🔒 Lock creati:
✅ .locks/[lockfile1] → [file1]
✅ .locks/[lockfile2] → [file2]
...

📊 Totale: [N] file lockati per questa sessione
```

---

### STEP 4: Mostra riepilogo

```
🔐 SESSIONE CONDIVISA ATTIVA

📋 File lockati da me:
- [file1]
- [file2]

⚠️ Regole:
- NON modificare file lockati da altre sessioni
- Prima di aggiungere nuovi file, verificare lock con `ls .locks/`
- A fine sessione, eseguire /stopsharedsession per rilasciare i lock

Procedo con l'implementazione?
```

---

### 🛑 STEP 5: FERMATI - Aspetta conferma

**NON procedere finché l'utente non conferma.**

---

## Aggiungere file durante la sessione

Se durante il lavoro scopri di dover toccare un file non previsto:

1. Verifica che non sia lockato: `ls .locks/ | grep [filename]`
2. Se libero, crea il lock
3. Se lockato, FERMATI e segnala

**OUTPUT:**
```
🔒 Lock aggiuntivo: [file] → .locks/[lockfile]
```

---

## Note

- I file `.locks/` sono in `.gitignore` — non vengono committati
- Ogni sessione è responsabile dei PROPRI lock
- Se una sessione crasha senza /stopsharedsession, i lock restano — l'utente li rimuove manualmente con `rm .locks/*`
