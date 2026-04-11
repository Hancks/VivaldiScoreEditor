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
        }
        .frame(minWidth: 36, minHeight: 44)
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
            Button("Delete", role: .destructive) {
                score.bars[barIndex].events.remove(at: eventIndex)
                onChanged()
            }
        }
    }

    // MARK: - Staff Preview

    private var staffPreview: some View {
        GroupBox("Staff Preview") {
            ScoreStaffPreview(score: score)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color(white: 0.95)))
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
