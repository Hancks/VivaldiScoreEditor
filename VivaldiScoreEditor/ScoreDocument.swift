import SwiftUI
import UniformTypeIdentifiers

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
        let data = try Data(contentsOf: url)
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

    func saveAs(_ url: URL) throws {
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
