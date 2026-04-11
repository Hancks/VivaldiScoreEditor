# TODO - Da fare

> Last updated: 2026-04-10

---

### 🔴🔴 CRITICO — Tipografia musicale (Music Engraving Engine)

Ogni elemento deve trovare il suo spazio senza conflitti. Le regole cambiano in base al contesto.

#### Regole da implementare:

1. **Gambi**: sopra la linea centrale → giù (a sinistra della testa). Sotto → su (a destra). Sulla linea centrale → dipende dal contesto (note vicine)
2. **In gruppi beamati**: la direzione del gambo è **uniforme** per tutto il gruppo, decisa dalla media delle posizioni
3. **Codine/flag**: sempre dal lato opposto alla testa rispetto al gambo
4. **Legature (tie)**: lato opposto ai gambi
5. **Slur (frase)**: lato opposto ai gambi, curva che abbraccia tutte le note senza toccarle
6. **Beams**: seguono l'inclinazione delle note (non orizzontali piatti), angolo limitato
7. **Bracket terzina/gruppo**: stesso lato del beam (o opposto ai gambi se non beamato)
8. **Pause nei gruppi**: posizionate per non interferire col beam
9. **Accidentali**: a sinistra della nota, scaglionate se vicine
10. **Spaziatura proporzionale**: durate più lunghe = più spazio orizzontale

**Obiettivo**: renderer da estrarre come libreria condivisa per Workshop, Keyboard e altre app.
**Richiede /add-task**

---

### 🔴 ALTA — Funzionalità editor

- [ ] Drag & drop per riordinare eventi dentro una battuta
- [ ] Copia/incolla battute
- [ ] Undo/redo
- [ ] Validazione: verificare che ogni battuta abbia la giusta durata totale
- [ ] Export: share sheet per condividere JSON
- [ ] Import da MusicXML (v2)

---

### 🟡 MEDIA — Miglioramenti UI

- [ ] Dark mode steampunk (portare SteampunkUI package)
- [ ] Preview audio: play score con sampler
- [ ] Keyboard shortcuts per editing rapido (macOS)

---

### 🟢 BASSA — Futuro

- [ ] Estrazione engine rendering in package condiviso `VivaldiMusicNotation`
- [ ] Supporto chiave di basso
- [ ] Supporto multi-voce (due voci sullo stesso pentagramma)
- [ ] Supporto dinamiche (p, f, crescendo)
