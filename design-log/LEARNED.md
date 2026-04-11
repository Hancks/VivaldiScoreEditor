# Learned - Competenze Acquisite

> Ultimo aggiornamento: 2026-04-10

---

## Music Engraving

- **Unicode musical symbols (𝅝, 𝅗𝅥, 𝄽) non rendono su macOS**: I glifi nel blocco Musical Symbols (U+1D100+) non sono supportati nei font di sistema. Usare Canvas/Path per disegnare. I simboli base (♩ U+2669, ♪ U+266A, ♯ U+266F, ♭ U+266D) funzionano
- **Gambi/legature opposite-side rule**: Gambi su → tie/slur sotto. Gambi giù → tie/slur sopra. Mai sovrapporre elementi grafici
- **Mixed beaming**: Note di durata diversa nello stesso beam group (es. croma puntata + terzina biscrome). Algoritmo: min(beamCount) barre su tutte, poi barre parziali per i sottogruppi con più beams
- **Pause di croma**: pallino nel 3° spazio (tra riga 3 B4 e riga 4 D5), codina che scende. NON sulla riga
- **staffPosition da MIDI (treble)**: `octave * 7 + naturalPos - 30` (E4=0). C=0, D=1, E=2, F=3, G=4, A=5, B=6
- **Armatura treble clef positions**: Diesis: F(8) C(5) G(9) D(6) A(3) E(7) B(4). Bemolli: B(4) E(7) A(3) D(6) G(2) C(5) F(1)

## SwiftUI / Xcode

- **PBXFileSystemSynchronizedRootGroup auto-discovery**: Xcode scopre tutti i .swift nella cartella. Per rimuovere un tipo duplicato (es. migrazione a package), il file locale va CANCELLATO fisicamente, non solo rimosso dal target
- **Codable init(from:) per JSON robusto**: `decodeIfPresent` con default per ogni campo opzionale. Gestisce sia campi assenti che `null` senza crash
- **Canvas multi-pass per notazione**: Pre-calcolare posizioni in struct (`PlacedEvent`), poi passate separate per staff/note/beams/ties/slur. Evita dipendenze circolari nel rendering

## Metodologia

- **NON inventare flussi UI nuovi**: Studiare come funzionano feature simili esistenti e seguire lo STESSO pattern
- **i18n: MAI inline ternary, SEMPRE switch su AppLanguage**: Consolidato in tutta la suite Vivaldi
