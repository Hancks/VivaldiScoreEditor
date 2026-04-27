import SwiftUI
import VivaldiScoreKit

struct ScoreDetailView: View {
    @Binding var score: VivaldiScore
    var onChanged: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                staffPreview
                headerSection
                metadataSection
                playbackHintSection
                dynamicSpansSection
                pedalMarksSection
                tempoChangesSection
                voicesSection
                barsSection
                jsonPreview
            }
            .padding(20)
        }
        .navigationTitle(score.title)
    }

    // MARK: - Header

    private var headerSection: some View {
        GroupBox("Score Info") {
            VStack(alignment: .leading, spacing: 12) {
                LabeledField("Title") {
                    TextField("Title", text: $score.title)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: score.title) { onChanged() }
                }
                LabeledField("Author") {
                    TextField("Author", text: $score.author)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: score.author) { onChanged() }
                }
                HStack(spacing: 20) {
                    LabeledField("Type") {
                        Picker("", selection: $score.scoreType) {
                            ForEach(ScoreType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .onChange(of: score.scoreType) { onChanged() }
                    }
                    LabeledField("Time Sig") {
                        HStack(spacing: 4) {
                            TextField("", value: $score.timeSignature.numerator, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)
                            Text("/")
                            TextField("", value: $score.timeSignature.denominator, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)
                        }
                        .onChange(of: score.timeSignature) { onChanged() }
                    }
                    LabeledField("Clef") {
                        let clefBinding = Binding<ScoreClef>(
                            get: { score.effectiveClef },
                            set: { score.clef = $0; onChanged() }
                        )
                        Picker("", selection: clefBinding) {
                            ForEach(ScoreClef.allCases, id: \.self) { c in
                                Text(c.displayName).tag(c)
                            }
                        }
                    }
                    LabeledField("Key (fifths)") {
                        let fifths = Binding<Int>(
                            get: { score.keySignature?.fifths ?? 0 },
                            set: { score.keySignature = ScoreKeySignature(fifths: $0); onChanged() }
                        )
                        Stepper("\(fifths.wrappedValue)", value: fifths, in: -7...7)
                    }
                }
                HStack(spacing: 20) {
                    Text("Bars: \(score.bars.count)")
                        .foregroundStyle(.secondary)
                    Text("Notes: \(score.totalNotes)")
                        .foregroundStyle(.secondary)
                    Text("Rests: \(score.totalRests)")
                        .foregroundStyle(.secondary)
                    if !score.pitchSequence.isEmpty {
                        Text("Pitches: \(score.pitchSequence.map { MidiHelper.noteName($0) }.joined(separator: " "))")
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(8)
        }
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        GroupBox("Metadata") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 20) {
                    LabeledField("Difficulty") {
                        let diff = Binding<Int>(
                            get: { score.metadata?.difficulty ?? 1 },
                            set: { ensureMetadata(); score.metadata?.difficulty = $0; onChanged() }
                        )
                        Stepper("\(diff.wrappedValue)", value: diff, in: 1...7)
                    }
                    LabeledField("Suggested BPM") {
                        let bpm = Binding<Int>(
                            get: { score.metadata?.suggestedBPM ?? 80 },
                            set: { ensureMetadata(); score.metadata?.suggestedBPM = $0; onChanged() }
                        )
                        Stepper("\(bpm.wrappedValue)", value: bpm, in: 30...300, step: 5)
                    }
                }
                LabeledField("Tags") {
                    let tags = Binding<String>(
                        get: { score.metadata?.tags?.joined(separator: ", ") ?? "" },
                        set: {
                            ensureMetadata()
                            score.metadata?.tags = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                            onChanged()
                        }
                    )
                    TextField("comma, separated, tags", text: tags)
                        .textFieldStyle(.roundedBorder)
                }
                LabeledField("Notes") {
                    let notes = Binding<String>(
                        get: { score.metadata?.notes ?? "" },
                        set: { ensureMetadata(); score.metadata?.notes = $0.isEmpty ? nil : $0; onChanged() }
                    )
                    TextField("Author notes", text: notes)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(8)
        }
    }

    private func ensureMetadata() {
        if score.metadata == nil {
            score.metadata = ScoreMetadata()
        }
    }

    // MARK: - Bars

    private var barsSection: some View {
        GroupBox("Bars (\(score.bars.count))") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(score.bars.enumerated()), id: \.offset) { barIndex, bar in
                    barView(barIndex: barIndex, bar: bar)
                }

                Button {
                    let beatsPerBar = score.timeSignature.numerator
                    let events = (0..<beatsPerBar).map { _ in ScoreEvent.note(.quarter) }
                    score.bars.append(ScoreBar(events: events))
                    onChanged()
                } label: {
                    Label("Add Bar", systemImage: "plus")
                }
                .padding(.top, 4)
            }
            .padding(8)
        }
    }

    private func barView(barIndex: Int, bar: ScoreBar) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Bar \(barIndex + 1)").font(.caption).fontWeight(.bold).foregroundStyle(.orange)
                Spacer()
                Text("\(String(format: "%.1f", bar.totalBeats)) beats")
                    .font(.caption2).foregroundStyle(.secondary)
                Button(role: .destructive) {
                    score.bars.remove(at: barIndex)
                    onChanged()
                } label: {
                    Image(systemName: "trash").font(.caption)
                }
                .buttonStyle(.plain)
            }
            HStack(spacing: 4) {
                ForEach(Array(bar.events.enumerated()), id: \.offset) { eventIndex, event in
                    eventBadge(event, barIndex: barIndex, eventIndex: eventIndex)
                }
                Button {
                    score.bars[barIndex].events.append(.note(.quarter))
                    onChanged()
                } label: {
                    Image(systemName: "plus.circle").font(.caption)
                }
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 6).fill(.quaternary.opacity(0.3)))
    }

    private func eventBadge(_ event: ScoreEvent, barIndex: Int, eventIndex: Int) -> some View {
        VStack(spacing: 1) {
            NoteIconView(
                duration: event.duration,
                isRest: event.isRest,
                color: event.isRest ? .gray : .primary
            )
            Text(event.duration.displayName)
                .font(.system(size: 7))
                .foregroundStyle(.secondary)
            if let p = event.pitch {
                Text(MidiHelper.noteName(p))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.orange)
            }
            HStack(spacing: 2) {
                if event.dotted { Text("dot").font(.system(size: 7)).foregroundStyle(.purple) }
                if event.tieToNext { Text("tie").font(.system(size: 7)).foregroundStyle(.blue) }
                if event.groupType != nil { Text("grp").font(.system(size: 7)).foregroundStyle(.green) }
            }
            // Playback metadata (1.30.0+): dynamic / articulation / velocity badge
            if event.dynamic != nil || event.articulation != nil || event.velocity != nil {
                HStack(spacing: 2) {
                    if let d = event.dynamic {
                        Text(d.displayName)
                            .font(.system(size: 8, weight: .bold, design: .serif).italic())
                            .foregroundStyle(.indigo)
                    }
                    if let a = event.articulation {
                        Text(articulationGlyph(a))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.teal)
                    }
                    if let v = event.velocity {
                        Text("v\(v)")
                            .font(.system(size: 7))
                            .foregroundStyle(.brown)
                    }
                }
            }
        }
        .frame(minWidth: 36, minHeight: 56)
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(event.isRest ? Color.gray.opacity(0.12) : Color.orange.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(event.isRest ? Color.gray.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
        )
        .contextMenu {
            Button("Toggle Rest") {
                score.bars[barIndex].events[eventIndex].isRest.toggle()
                onChanged()
            }
            Button("Toggle Dotted") {
                score.bars[barIndex].events[eventIndex].dotted.toggle()
                onChanged()
            }
            Button("Toggle Tie") {
                score.bars[barIndex].events[eventIndex].tieToNext.toggle()
                onChanged()
            }
            Menu("Duration") {
                ForEach(RhythmDuration.allCases, id: \.self) { dur in
                    Button("\(dur.symbol) \(dur.displayName)") {
                        score.bars[barIndex].events[eventIndex].duration = dur
                        onChanged()
                    }
                }
            }
            if score.scoreType != .rhythm {
                Menu("Pitch") {
                    ForEach(48...84, id: \.self) { midi in
                        Button(MidiHelper.noteName(midi)) {
                            score.bars[barIndex].events[eventIndex].pitch = midi
                            onChanged()
                        }
                    }
                }
            }
            Divider()
            Menu("Dynamic") {
                Button("None") {
                    score.bars[barIndex].events[eventIndex].dynamic = nil; onChanged()
                }
                ForEach(ScoreDynamic.allCases, id: \.self) { d in
                    Button("\(d.displayName) (vel \(d.velocity))") {
                        score.bars[barIndex].events[eventIndex].dynamic = d; onChanged()
                    }
                }
            }
            Menu("Articulation") {
                Button("None") {
                    score.bars[barIndex].events[eventIndex].articulation = nil; onChanged()
                }
                ForEach(ScoreArticulation.allCases, id: \.self) { a in
                    Button("\(articulationGlyph(a)) \(a.rawValue)") {
                        score.bars[barIndex].events[eventIndex].articulation = a; onChanged()
                    }
                }
            }
            Divider()
            Button("Delete", role: .destructive) {
                score.bars[barIndex].events.remove(at: eventIndex)
                onChanged()
            }
        }
    }

    /// Glifo Unicode per articolazione (badge piccolo, non chord-grade).
    private func articulationGlyph(_ a: ScoreArticulation) -> String {
        switch a {
        case .staccato:      return "•"
        case .staccatissimo: return "‡"
        case .tenuto:        return "—"
        case .accent:        return ">"
        case .marcato:       return "^"
        case .legato:        return "~"
        case .fermata:       return "𝄐"
        }
    }

    // MARK: - Staff Preview

    private var staffPreview: some View {
        // NIENTE GroupBox: GroupBox forza il content alla larghezza del parent,
        // impedendo allo ScrollView(.horizontal) interno a ScoreStaffPreview di
        // mostrare il contenuto più largo dello schermo. Usiamo un VStack
        // con label manuale e contenitore senza vincoli di width.
        VStack(alignment: .leading, spacing: 4) {
            Text("Staff Preview")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            ScoreStaffPreview(score: score)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color(white: 0.95)))
        }
    }

    // MARK: - Playback metadata (1.30.0+)

    /// SoundFont hint: bank + program + display name. Mostrato in lettura+modifica.
    private var playbackHintSection: some View {
        GroupBox("Playback — SoundFont Hint") {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Has SoundFont hint", isOn: Binding(
                    get: { score.soundFontHint != nil },
                    set: { newVal in
                        if newVal && score.soundFontHint == nil {
                            score.soundFontHint = ScoreSoundFontHint(bank: 0, program: 0, displayName: "Acoustic Grand Piano")
                        } else if !newVal {
                            score.soundFontHint = nil
                        }
                        onChanged()
                    }
                ))
                if let hint = score.soundFontHint {
                    HStack(spacing: 16) {
                        LabeledField("Display Name") {
                            TextField("Display name", text: Binding(
                                get: { hint.displayName ?? "" },
                                set: { score.soundFontHint?.displayName = $0.isEmpty ? nil : $0; onChanged() }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .frame(minWidth: 200)
                        }
                        LabeledField("Bank") {
                            TextField("", value: Binding(
                                get: { hint.bank },
                                set: { score.soundFontHint?.bank = $0; onChanged() }
                            ), format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        }
                        LabeledField("Program (GM)") {
                            TextField("", value: Binding(
                                get: { hint.program },
                                set: { score.soundFontHint?.program = $0; onChanged() }
                            ), format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        }
                        LabeledField("Fallback to user") {
                            Toggle("", isOn: Binding(
                                get: { hint.fallbackToUserSelection },
                                set: { score.soundFontHint?.fallbackToUserSelection = $0; onChanged() }
                            )).labelsHidden()
                        }
                    }
                }
            }
            .padding(8)
        }
    }

    /// Crescendo / decrescendo span list. Aggiungi/rimuovi con bottone.
    private var dynamicSpansSection: some View {
        GroupBox("Playback — Dynamic Spans (\(score.dynamicSpans?.count ?? 0))") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array((score.dynamicSpans ?? []).enumerated()), id: \.offset) { idx, span in
                    HStack(spacing: 8) {
                        Text(span.isCrescendo ? "<" : ">")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(span.isCrescendo ? .green : .orange)
                            .frame(width: 24)
                        LabeledField("Beats") {
                            HStack(spacing: 4) {
                                TextField("", value: bindSpan(idx, \.startBeat), format: .number).textFieldStyle(.roundedBorder).frame(width: 60)
                                Text("→")
                                TextField("", value: bindSpan(idx, \.endBeat), format: .number).textFieldStyle(.roundedBorder).frame(width: 60)
                            }
                        }
                        LabeledField("From") {
                            Picker("", selection: bindSpan(idx, \.fromDynamic)) {
                                ForEach(ScoreDynamic.allCases, id: \.self) { d in
                                    Text(d.displayName).tag(d)
                                }
                            }
                        }
                        LabeledField("To") {
                            Picker("", selection: bindSpan(idx, \.toDynamic)) {
                                ForEach(ScoreDynamic.allCases, id: \.self) { d in
                                    Text(d.displayName).tag(d)
                                }
                            }
                        }
                        Spacer()
                        Button(role: .destructive) {
                            score.dynamicSpans?.remove(at: idx)
                            if score.dynamicSpans?.isEmpty == true { score.dynamicSpans = nil }
                            onChanged()
                        } label: { Image(systemName: "trash") }
                        .buttonStyle(.plain)
                    }
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 4).fill(.quaternary.opacity(0.3)))
                }
                Button {
                    var arr = score.dynamicSpans ?? []
                    arr.append(ScoreDynamicSpan(startBeat: 0, endBeat: 4, fromDynamic: .p, toDynamic: .f))
                    score.dynamicSpans = arr
                    onChanged()
                } label: {
                    Label("Add crescendo / decrescendo", systemImage: "plus")
                }
            }
            .padding(8)
        }
    }

    /// Indicazioni di pedale (sustain/sostenuto/soft) con range in beat.
    private var pedalMarksSection: some View {
        GroupBox("Playback — Pedal Marks (\(score.pedalMarks?.count ?? 0))") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array((score.pedalMarks ?? []).enumerated()), id: \.offset) { idx, mark in
                    HStack(spacing: 8) {
                        Image(systemName: pedalIcon(mark.kind))
                            .foregroundStyle(.brown)
                            .frame(width: 24)
                        LabeledField("Kind") {
                            Picker("", selection: bindPedal(idx, \.kind)) {
                                Text("Sustain").tag(ScorePedalMark.Kind.sustain)
                                Text("Sostenuto").tag(ScorePedalMark.Kind.sostenuto)
                                Text("Soft").tag(ScorePedalMark.Kind.soft)
                            }
                        }
                        LabeledField("Beats") {
                            HStack(spacing: 4) {
                                TextField("", value: bindPedal(idx, \.startBeat), format: .number).textFieldStyle(.roundedBorder).frame(width: 60)
                                Text("→")
                                TextField("", value: bindPedal(idx, \.endBeat), format: .number).textFieldStyle(.roundedBorder).frame(width: 60)
                            }
                        }
                        LabeledField("Release fraction") {
                            TextField("", value: bindPedal(idx, \.releaseFraction), format: .number).textFieldStyle(.roundedBorder).frame(width: 60)
                        }
                        Spacer()
                        Button(role: .destructive) {
                            score.pedalMarks?.remove(at: idx)
                            if score.pedalMarks?.isEmpty == true { score.pedalMarks = nil }
                            onChanged()
                        } label: { Image(systemName: "trash") }
                        .buttonStyle(.plain)
                    }
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 4).fill(.quaternary.opacity(0.3)))
                }
                Button {
                    var arr = score.pedalMarks ?? []
                    arr.append(ScorePedalMark(kind: .sustain, startBeat: 0, endBeat: 4))
                    score.pedalMarks = arr
                    onChanged()
                } label: {
                    Label("Add pedal mark", systemImage: "plus")
                }
            }
            .padding(8)
        }
    }

    /// Cambi di tempo (BPM) — il primo è in metadata.suggestedBPM.
    private var tempoChangesSection: some View {
        GroupBox("Playback — Tempo Changes (\(score.tempoChanges?.count ?? 0))") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array((score.tempoChanges ?? []).enumerated()), id: \.offset) { idx, tc in
                    HStack(spacing: 8) {
                        Image(systemName: "metronome.fill")
                            .foregroundStyle(.blue)
                            .frame(width: 24)
                        LabeledField("Start beat") {
                            TextField("", value: bindTempo(idx, \.startBeat), format: .number).textFieldStyle(.roundedBorder).frame(width: 70)
                        }
                        LabeledField("BPM") {
                            TextField("", value: bindTempo(idx, \.bpm), format: .number).textFieldStyle(.roundedBorder).frame(width: 70)
                        }
                        LabeledField("Transition") {
                            Picker("", selection: bindTempo(idx, \.transition)) {
                                Text("Immediate").tag(ScoreTempoChange.Transition.immediate)
                                Text("Ritardando").tag(ScoreTempoChange.Transition.ritardando)
                                Text("Accelerando").tag(ScoreTempoChange.Transition.accelerando)
                            }
                        }
                        Spacer()
                        Button(role: .destructive) {
                            score.tempoChanges?.remove(at: idx)
                            if score.tempoChanges?.isEmpty == true { score.tempoChanges = nil }
                            onChanged()
                        } label: { Image(systemName: "trash") }
                        .buttonStyle(.plain)
                    }
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 4).fill(.quaternary.opacity(0.3)))
                }
                Button {
                    var arr = score.tempoChanges ?? []
                    arr.append(ScoreTempoChange(startBeat: 0, bpm: 120, transition: .immediate))
                    score.tempoChanges = arr
                    onChanged()
                } label: {
                    Label("Add tempo change", systemImage: "plus")
                }
            }
            .padding(8)
        }
    }

    /// Voci multi-staff (es. mano destra + mano sinistra). MVP: read-only summary.
    private var voicesSection: some View {
        GroupBox("Playback — Voices (\(score.voices?.count ?? 0))") {
            VStack(alignment: .leading, spacing: 8) {
                if let voices = score.voices, !voices.isEmpty {
                    ForEach(Array(voices.enumerated()), id: \.offset) { _, v in
                        HStack(spacing: 12) {
                            Image(systemName: "music.note.list")
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(v.label ?? v.id).font(.headline)
                                Text("\(v.clef.displayName) — \(v.bars.count) bars — \(v.bars.flatMap { $0.events }.filter { !$0.isRest }.count) notes")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let hint = v.soundFontHint {
                                    Text("SF hint: \(hint.displayName ?? "GM \(hint.program)") (bank \(hint.bank), prog \(hint.program))")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            Spacer()
                        }
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.quaternary.opacity(0.3)))
                    }
                } else {
                    Text("No voices defined. Top-level `bars` is the main timeline.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("Multi-voice editing planned for next release. For now use a JSON editor.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(8)
        }
    }

    // MARK: - Bindings helper for indexed playback arrays

    private func bindSpan<T>(_ idx: Int, _ kp: WritableKeyPath<ScoreDynamicSpan, T>) -> Binding<T> {
        Binding(
            get: { score.dynamicSpans![idx][keyPath: kp] },
            set: { score.dynamicSpans![idx][keyPath: kp] = $0; onChanged() }
        )
    }
    private func bindPedal<T>(_ idx: Int, _ kp: WritableKeyPath<ScorePedalMark, T>) -> Binding<T> {
        Binding(
            get: { score.pedalMarks![idx][keyPath: kp] },
            set: { score.pedalMarks![idx][keyPath: kp] = $0; onChanged() }
        )
    }
    private func bindTempo<T>(_ idx: Int, _ kp: WritableKeyPath<ScoreTempoChange, T>) -> Binding<T> {
        Binding(
            get: { score.tempoChanges![idx][keyPath: kp] },
            set: { score.tempoChanges![idx][keyPath: kp] = $0; onChanged() }
        )
    }

    private func pedalIcon(_ kind: ScorePedalMark.Kind) -> String {
        switch kind {
        case .sustain:   return "wave.3.right"
        case .sostenuto: return "circle.dashed.inset.filled"
        case .soft:      return "speaker.wave.1.fill"
        }
    }

    // MARK: - JSON Preview

    private var jsonPreview: some View {
        GroupBox("JSON") {
            if let data = score.toJSON(), let text = String(data: data, encoding: .utf8) {
                ScrollView([.horizontal, .vertical]) {
                    Text(text)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 400)
            }
        }
    }
}

// MARK: - Helpers

struct LabeledField<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content
    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            content
        }
    }
}

enum MidiHelper {
    private static let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    static func noteName(_ midi: Int) -> String {
        let note = noteNames[midi % 12]
        let octave = midi / 12 - 1
        return "\(note)\(octave)"
    }
}
