import Foundation

// MARK: - VivaldiScore Format (standalone copy for editor)

struct VivaldiScore: Codable, Identifiable {
    var id: String
    var version: Int
    var title: String
    var author: String
    var createdDate: Date
    var scoreType: ScoreType
    var timeSignature: ScoreTimeSignature
    var keySignature: ScoreKeySignature?
    var clef: ScoreClef?  // nil = treble (backward compatible)
    var bars: [ScoreBar]
    var metadata: ScoreMetadata?

    /// Chiave effettiva (default treble se nil)
    var effectiveClef: ScoreClef { clef ?? .treble }

    init(
        id: String = UUID().uuidString,
        version: Int = 1,
        title: String,
        author: String = "Vivaldi App",
        createdDate: Date = Date(),
        scoreType: ScoreType,
        timeSignature: ScoreTimeSignature,
        keySignature: ScoreKeySignature? = nil,
        clef: ScoreClef? = nil,
        bars: [ScoreBar],
        metadata: ScoreMetadata? = nil
    ) {
        self.id = id
        self.version = version
        self.title = title
        self.author = author
        self.createdDate = createdDate
        self.scoreType = scoreType
        self.timeSignature = timeSignature
        self.keySignature = keySignature
        self.clef = clef
        self.bars = bars
        self.metadata = metadata
    }

    var totalBeats: Double { Double(bars.count) * Double(timeSignature.numerator) }
    var totalNotes: Int { bars.flatMap { $0.events }.filter { !$0.isRest }.count }
    var totalRests: Int { bars.flatMap { $0.events }.filter { $0.isRest }.count }

    var pitchSequence: [Int] {
        guard scoreType != .rhythm else { return [] }
        return bars.flatMap { $0.events }.filter { !$0.isRest }.compactMap { $0.pitch }
    }

    func toJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(self)
    }

    static func fromJSON(_ data: Data) -> VivaldiScore? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(VivaldiScore.self, from: data)
    }
}

enum ScoreType: String, Codable, CaseIterable {
    case rhythm, pitch, mixed
}

// MARK: - Setticlavio (7 clefs)

enum ScoreClef: String, Codable, CaseIterable {
    case treble         // Chiave di Sol — G4 sulla 2a riga
    case bass           // Chiave di Fa — F3 sulla 4a riga
    case soprano        // Chiave di Do — C4 sulla 1a riga
    case mezzoSoprano   // Chiave di Do — C4 sulla 2a riga
    case alto           // Chiave di Do — C4 sulla 3a riga (viola)
    case tenor          // Chiave di Do — C4 sulla 4a riga
    case baritone       // Chiave di Fa — F3 sulla 3a riga

    /// Offset per convertire MIDI → staffPosition (0 = prima riga del pentagramma)
    var staffOffset: Int {
        switch self {
        case .treble:       return 37
        case .bass:         return 25
        case .soprano:      return 35
        case .mezzoSoprano: return 33
        case .alto:         return 31
        case .tenor:        return 29
        case .baritone:     return 27
        }
    }

    /// Simbolo Unicode della chiave
    var symbol: String {
        switch self {
        case .treble:                                return "𝄞"
        case .bass, .baritone:                       return "𝄢"
        case .soprano, .mezzoSoprano, .alto, .tenor: return "𝄡"
        }
    }

    /// Riga del pentagramma su cui si centra il simbolo (0=prima riga, 4=quinta riga)
    var symbolLineIndex: Int {
        switch self {
        case .treble:       return 1  // Sol sulla 2a riga
        case .bass:         return 3  // Fa sulla 4a riga
        case .soprano:      return 0  // Do sulla 1a riga
        case .mezzoSoprano: return 1  // Do sulla 2a riga
        case .alto:         return 2  // Do sulla 3a riga
        case .tenor:        return 3  // Do sulla 4a riga
        case .baritone:     return 2  // Fa sulla 3a riga
        }
    }

    /// Dimensione font per il simbolo chiave (il Sol è più grande del Do/Fa)
    var symbolFontScale: CGFloat {
        switch self {
        case .treble: return 6.5
        case .bass, .baritone: return 4.0
        case .soprano, .mezzoSoprano, .alto, .tenor: return 4.5
        }
    }

    /// Posizioni delle alterazioni in chiave (diesis) — staffPos per ogni diesis nell'ordine F C G D A E B
    var keySigSharpPositions: [Int] {
        switch self {
        case .treble:       return [8, 5, 9, 6, 3, 7, 4]
        case .bass:         return [6, 3, 7, 4, 1, 5, 2]
        case .soprano:      return [4, 1, 5, 2, 6, 3, 7]
        case .mezzoSoprano: return [6, 3, 7, 4, 1, 5, 2]
        case .alto:         return [7, 4, 8, 5, 2, 6, 3]
        case .tenor:        return [5, 2, 6, 3, 0, 4, 1]
        case .baritone:     return [5, 2, 6, 3, 0, 4, 1]
        }
    }

    /// Posizioni delle alterazioni in chiave (bemolli) — staffPos per ogni bemolle nell'ordine B E A D G C F
    var keySigFlatPositions: [Int] {
        switch self {
        case .treble:       return [4, 7, 3, 6, 2, 5, 1]
        case .bass:         return [2, 5, 1, 4, 0, 3, 6]
        case .soprano:      return [0, 3, 6, 2, 5, 1, 4]
        case .mezzoSoprano: return [2, 5, 1, 4, 0, 3, 6]
        case .alto:         return [3, 6, 2, 5, 1, 4, 0]
        case .tenor:        return [1, 4, 0, 3, 6, 2, 5]
        case .baritone:     return [1, 4, 0, 3, 6, 2, 5]
        }
    }

    var displayName: String {
        switch self {
        case .treble:       return "Sol (Violino)"
        case .bass:         return "Fa (Basso)"
        case .soprano:      return "Do (Soprano)"
        case .mezzoSoprano: return "Do (Mezzosoprano)"
        case .alto:         return "Do (Contralto)"
        case .tenor:        return "Do (Tenore)"
        case .baritone:     return "Fa (Baritono)"
        }
    }
}

struct ScoreTimeSignature: Codable, Equatable {
    var numerator: Int
    var denominator: Int
    var displayString: String { "\(numerator)/\(denominator)" }
    static let common44 = ScoreTimeSignature(numerator: 4, denominator: 4)
    static let common34 = ScoreTimeSignature(numerator: 3, denominator: 4)
    static let common24 = ScoreTimeSignature(numerator: 2, denominator: 4)
    static let common68 = ScoreTimeSignature(numerator: 6, denominator: 8)
}

struct ScoreKeySignature: Codable, Equatable {
    var fifths: Int
    var mode: KeyMode?
    enum KeyMode: String, Codable { case major, minor }
    static let cMajor = ScoreKeySignature(fifths: 0, mode: .major)
}

struct ScoreBar: Codable {
    var events: [ScoreEvent]
    var totalBeats: Double { events.reduce(0) { $0 + $1.totalBeats } }
}

struct ScoreEvent: Codable {
    var duration: RhythmDuration
    var isRest: Bool
    var pitch: Int?
    var dotted: Bool
    var tieToNext: Bool
    var groupId: Int?
    var groupType: GroupType?
    var groupPosition: GroupPosition?
    /// Legatura di frase (slur): numero di note successive coperte dall'arco.
    /// Es. slurLength=2 → arco da questa nota fino a 2 note dopo.
    /// nil = nessuno slur. Diverso da tieToNext (legatura di valore = stessa altezza).
    var slurLength: Int?

    init(
        duration: RhythmDuration, isRest: Bool = false, pitch: Int? = nil,
        dotted: Bool = false, tieToNext: Bool = false,
        groupId: Int? = nil, groupType: GroupType? = nil, groupPosition: GroupPosition? = nil,
        slurLength: Int? = nil
    ) {
        self.duration = duration; self.isRest = isRest; self.pitch = pitch
        self.dotted = dotted; self.tieToNext = tieToNext
        self.groupId = groupId; self.groupType = groupType; self.groupPosition = groupPosition
        self.slurLength = slurLength
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        duration = try c.decode(RhythmDuration.self, forKey: .duration)
        isRest = try c.decodeIfPresent(Bool.self, forKey: .isRest) ?? false
        pitch = try c.decodeIfPresent(Int.self, forKey: .pitch)
        dotted = try c.decodeIfPresent(Bool.self, forKey: .dotted) ?? false
        tieToNext = try c.decodeIfPresent(Bool.self, forKey: .tieToNext) ?? false
        groupId = try c.decodeIfPresent(Int.self, forKey: .groupId)
        groupType = try c.decodeIfPresent(GroupType.self, forKey: .groupType)
        groupPosition = try c.decodeIfPresent(GroupPosition.self, forKey: .groupPosition)
        slurLength = try c.decodeIfPresent(Int.self, forKey: .slurLength)
    }

    var totalBeats: Double { dotted ? duration.beats * 1.5 : duration.beats }

    static func note(_ d: RhythmDuration, dotted: Bool = false, pitch: Int? = nil, tieToNext: Bool = false) -> ScoreEvent {
        ScoreEvent(duration: d, isRest: false, pitch: pitch, dotted: dotted, tieToNext: tieToNext)
    }
    static func rest(_ d: RhythmDuration, dotted: Bool = false) -> ScoreEvent {
        ScoreEvent(duration: d, isRest: true, dotted: dotted)
    }
}

enum GroupType: String, Codable {
    case beam, triplet, quintuplet, sextuplet, septuplet

    var groupNumber: Int {
        switch self {
        case .beam: return 0
        case .triplet: return 3
        case .quintuplet: return 5
        case .sextuplet: return 6
        case .septuplet: return 7
        }
    }
}
enum GroupPosition: String, Codable { case first, middle, last, solo }

enum RhythmDuration: String, Codable, CaseIterable {
    case whole, half, quarter, eighth, sixteenth, thirtySecond, triplet, quarterTriplet

    var beats: Double {
        switch self {
        case .whole: return 4.0; case .half: return 2.0; case .quarter: return 1.0
        case .eighth: return 0.5; case .sixteenth: return 0.25; case .thirtySecond: return 0.125
        case .triplet: return 1.0 / 3.0; case .quarterTriplet: return 2.0 / 3.0
        }
    }

    var symbol: String {
        switch self {
        case .whole: return "○"; case .half: return "◑"; case .quarter: return "●"
        case .eighth: return "♪"; case .sixteenth: return "♬"; case .thirtySecond: return "♬♬"
        case .triplet: return "³♪"; case .quarterTriplet: return "³●"
        }
    }

    var displayName: String {
        switch self {
        case .whole: return "Whole"; case .half: return "Half"; case .quarter: return "Quarter"
        case .eighth: return "Eighth"; case .sixteenth: return "16th"; case .thirtySecond: return "32nd"
        case .triplet: return "Triplet"; case .quarterTriplet: return "Quarter Triplet"
        }
    }

    var isFilledHead: Bool {
        switch self { case .whole, .half: return false; default: return true }
    }

    var hasStem: Bool { self != .whole }

    var beamCount: Int {
        switch self {
        case .whole, .half, .quarter, .quarterTriplet: return 0
        case .eighth, .triplet: return 1
        case .sixteenth: return 2
        case .thirtySecond: return 3
        }
    }
}

struct ScoreMetadata: Codable {
    var difficulty: Int?
    var tags: [String]?
    var suggestedBPM: Int?
    var notes: String?
    var source: String?
}
