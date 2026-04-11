# Set Icon/Image Command

Ottimizza e installa un'immagine nel progetto Xcode, ridimensionandola per la destinazione specificata.

## Usage

```
/set-iconimage <percorso_immagine> <destinazione> [nome_asset]
```

Esempi:
```
/set-iconimage ~/Downloads/sax.png instrument alto_sax
/set-iconimage ~/Desktop/logo.png appicon
/set-iconimage ~/img/ritmo.jpeg menu-tile trainer_rhythm
/set-iconimage ~/img/categoria.png category woodwinds
```

---

## STEP OBBLIGATORI

### STEP 1: Verifica immagine sorgente

Verifica che il file esista e leggine le dimensioni.

```bash
sips -g pixelWidth -g pixelHeight <percorso_immagine>
```

**OUTPUT OBBLIGATORIO:**
```
🖼️ Immagine sorgente:
✅ File: [percorso]
✅ Formato: [jpeg/png]
✅ Dimensioni: [W]x[H] px
```

Se il file non esiste:
```
❌ File non trovato: [percorso]
```
→ FERMATI

---

### STEP 2: Identifica destinazione e parametri

Le destinazioni supportate e le loro specifiche:

| Destinazione | Dimensione @1x | Formato | Naming pattern |
|-------------|----------------|---------|----------------|
| `menu-tile` | 1024x1024 | JPEG quality 0.8 | `Vivaldi_[nome].jpeg` |
| `instrument` | 256x256 | JPEG quality 0.85 | `instrument_[nome].jpeg` |
| `category` | 256x256 | JPEG quality 0.85 | `instrument_[nome].jpeg` |
| `appicon` | 1024x1024 | PNG | `[nome].png` |
| `splash` | 1024x1024 | JPEG quality 0.8 | `Vivaldi_[nome].jpeg` |

**OUTPUT OBBLIGATORIO:**
```
🎯 Destinazione: [tipo]
📐 Dimensione target: [W]x[H] px (@1x, universal)
📁 Asset path: Vivaldi/Assets.xcassets/[nome].imageset/
📄 Nome file: [filename]
```

Se la destinazione non è riconosciuta, chiedere:
```
❓ Destinazione "[input]" non riconosciuta.
Destinazioni valide: menu-tile, instrument, category, appicon, splash
Quale intendevi?
```

---

### STEP 3: Verifica se l'asset esiste già

Controlla se l'imageset esiste già in xcassets.

**Se esiste:**
```
⚠️ L'asset [nome] esiste già in xcassets.
Vuoi sovrascriverlo? (sì/no)
```
→ Aspetta conferma

**Se non esiste:**
```
✅ Asset [nome] non esiste — verrà creato
```

---

### STEP 4: Ottimizza e copia

1. **Crea la cartella imageset** (se non esiste):
```bash
mkdir -p Vivaldi/Vivaldi/Assets.xcassets/[nome].imageset
```

2. **Ridimensiona e converti** con `sips`:
```bash
# Per JPEG:
sips -z [H] [W] --setProperty format jpeg --setProperty formatOptions [quality] <sorgente> --out <destinazione>

# Per PNG:
sips -z [H] [W] --setProperty format png <sorgente> --out <destinazione>
```

3. **Crea Contents.json**:
```json
{
  "images" : [
    {
      "filename" : "[filename]",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**Per appicon** usa il formato AppIcon specifico:
```json
{
  "images" : [
    {
      "filename" : "[filename]",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**OUTPUT OBBLIGATORIO:**
```
🔨 Elaborazione:
✅ Ridimensionato: [orig_W]x[orig_H] → [target_W]x[target_H]
✅ Formato: [formato] (quality: [Q])
✅ Copiato in: Vivaldi/Assets.xcassets/[nome].imageset/[filename]
✅ Contents.json creato
```

---

### STEP 5: Verifica finale

```bash
# Verifica che il file esista e abbia le dimensioni corrette
sips -g pixelWidth -g pixelHeight <file_destinazione>
# Verifica dimensione file
ls -lh <file_destinazione>
```

**OUTPUT OBBLIGATORIO:**
```
✅ IMMAGINE INSTALLATA

📁 Asset: [nome].imageset
🖼️ File: [filename]
📐 Dimensioni: [W]x[H] px
💾 Peso: [size]
🎯 Destinazione: [tipo]

Per usarla nel codice Swift:
Image("[nome_asset]")
```

---

## Note

- Le immagini sono solo @1x (universal) — Xcode gestisce il ridimensionamento per schermi @2x/@3x
- Per le menu-tile da 1024x1024: servono immagini di partenza >= 1024px per qualità ottimale
- Per gli strumenti da 256x256: immagini >= 512px sono ideali
- Se l'immagine sorgente è più piccola della destinazione, avvisare:
  ```
  ⚠️ L'immagine sorgente ([W]x[H]) è più piccola della destinazione ([TW]x[TH]).
  La qualità potrebbe risentirne. Procedere comunque? (sì/no)
  ```
- Il percorso xcassets è: `Vivaldi/Vivaldi/Assets.xcassets/`
- Dopo l'installazione, ricordare all'utente di verificare in Xcode che l'asset sia visibile
