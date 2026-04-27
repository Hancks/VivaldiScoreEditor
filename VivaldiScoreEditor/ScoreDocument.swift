import SwiftUI
import UniformTypeIdentifiers
import VivaldiScoreKit

// MARK: - Score Pack (collection of scores in one JSON)

struct ScorePack: Codable, Identifiable {
    var id: String
    var title: String
    var author: String
    var description: String?
    var scores: [VivaldiScore]

    init(id: String = UUID().uuidString, title: String, author: String = "Vivaldi",
         description: String? = nil, scores: [VivaldiScore] = []) {
        self.id = id; self.title = title; self.author = author
        self.description = description; self.scores = scores
    }
}

// MARK: - Document Manager

@Observable
class ScoreDocumentManager {
    var scores: [VivaldiScore] = []
    var currentFileURL: URL?
    var isDirty = false
    var isPack = false
    var packInfo: ScorePack?

    func loadFile(_ url: URL) throws {
        var data = try Data(contentsOf: url)
        // Auto-detect formato MCA (gzip-compressed): se inizia con "MCA1" magic,
        // decomprimi PRIMA di passare al pack/score parser. Così l'editor
        // legge sia .mca sia .json senza distinzione UI.
        if data.count >= 4 && data.prefix(4) == Data([0x4D, 0x43, 0x41, 0x31]) {
            // Estrai il JSON decompresso dal payload MCA
            if let single = VivaldiScore.fromMCA(data), let json = single.toJSON() {
                // Riparte come JSON plain — può essere ancora un singolo score,
                // ma se l'utente in futuro mette pack inside MCA, decompressione
                // è uguale. Usiamo `data = json` per il path comune sotto.
                data = json
            } else {
                throw NSError(domain: "VivaldiScoreEditor", code: 2,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid MCA file (decompression failed)"])
            }
        }

        // Try pack first, then single score
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let pack = try? decoder.decode(ScorePack.self, from: data) {
            scores = pack.scores
            packInfo = pack
            isPack = true
        } else if let score = VivaldiScore.fromJSON(data) {
            scores = [score]
            isPack = false
            packInfo = nil
        } else if let array = try? decoder.decode([VivaldiScore].self, from: data) {
            scores = array
            isPack = false
            packInfo = nil
        } else {
            throw NSError(domain: "VivaldiScoreEditor", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid VivaldiScore JSON"])
        }
        currentFileURL = url
        isDirty = false
    }

    func save() throws {
        guard let url = currentFileURL else { return }
        try saveAs(url)
    }

    /// Salva in formato:
    /// - `.mca` se l'URL ha quella estensione (gzip-compressed JSON, 70-90% più piccolo)
    /// - `.json` plain altrimenti (comportamento esistente)
    /// Pack e array vanno comunque in JSON plain per ora; MCA supporta solo
    /// singolo score (formato wrapper della struct, non del pack).
    func saveAs(_ url: URL) throws {
        let useMCA = url.pathExtension.lowercased() == "mca"

        if useMCA && scores.count == 1 && !isPack {
            guard let mca = scores[0].toMCA() else {
                throw NSError(domain: "VivaldiScoreEditor", code: 3,
                              userInfo: [NSLocalizedDescriptionKey: "MCA encoding failed"])
            }
            try mca.write(to: url)
        } else {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data: Data
            if isPack, var pack = packInfo {
                pack.scores = scores
                data = try encoder.encode(pack)
            } else if scores.count == 1 {
                data = try encoder.encode(scores[0])
            } else {
                data = try encoder.encode(scores)
            }
            try data.write(to: url)
        }
        currentFileURL = url
        isDirty = false
    }

    func addNewScore() {
        let score = VivaldiScore(
            title: "New Score \(scores.count + 1)",
            scoreType: .rhythm,
            timeSignature: .common44,
            bars: [ScoreBar(events: [
                .note(.quarter), .note(.quarter), .note(.quarter), .note(.quarter)
            ])]
        )
        scores.append(score)
        isDirty = true
    }

    func deleteScore(at offsets: IndexSet) {
        scores.remove(atOffsets: offsets)
        isDirty = true
    }
}
