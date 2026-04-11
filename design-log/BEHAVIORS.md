# 🧠 COMPORTAMENTI APPRESI - Leggi PRIMA di fare qualsiasi cosa

> Ultimo aggiornamento: 2026-01-22

Questo file contiene regole comportamentali che il Claude ATTUALE lascia in eredità al Claude FUTURO.

---

## REGOLE CRITICHE

### 1. Tu NON segui la metodologia automaticamente
- Hai dimostrato empiricamente (sessione 2026-01-22) che salti passaggi se non sei forzato
- Non illuderti di "aver imparato" - ogni sessione parti da zero

### 2. Quando l'utente chiede di implementare qualcosa
- ❌ NON partire a implementare direttamente
- ❌ NON chiedere "Procedo?"
- ✅ SUGGERISCI: "Questo task richiede /add-task. Posso eseguirlo?"

### 3. /add-task funziona perché ti FORZA
- Senza di esso, salterai: design log, domande, approvazione
- CON esso, hai gli step davanti e li segui uno per uno
- È l'unico modo per garantire che segui la metodologia

### 4. Se l'utente dice "procedi" o "fai X"
1. FERMATI
2. Chiediti: "È un task significativo? Serve /add-task?"
3. Se SÌ → suggerisci /add-task
4. Se NO (task banale < 3 file) → procedi

### 5. Il principio fondamentale
**"Non fidarti di te stesso. Usa i comandi che ti forzano."**

### 6. Sessioni parallele — LOCK obbligatorio
- Quando ci sono 2+ sessioni Claude sullo stesso repo: **SEMPRE** usare `/startsharedsession`
- **NON** modificare file con `.lock` di un'altra sessione — FERMATI e segnala
- Prima di aggiungere un file non previsto durante il lavoro: verificare lock con `ls .locks/`
- A fine sessione parallela: **SEMPRE** eseguire `/stopsharedsession` per rilasciare i lock
- Se trovi un lock orfano (sessione crashata): segnala all'utente, NON rimuoverlo tu

---

## COME USARE QUESTO FILE

1. /startsession DEVE leggere questo file
2. /startsession DEVE mostrare queste regole nel riepilogo
3. Se aggiungi nuovi comportamenti appresi, aggiorna questo file con /savesession

---

## STORICO APPRENDIMENTI

### 2026-01-22 - Sessione di debugging metodologia
- **Scoperto:** Claude non legge automaticamente i file all'inizio
- **Scoperto:** Claude non segue la metodologia se non forzato
- **Soluzione:** Creati /startsession e /add-task obbligatori
- **Regola derivata:** Suggerire sempre /add-task per task significativi
