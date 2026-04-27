import SwiftUI
import UniformTypeIdentifiers
import VivaldiScoreKit

/// UTType per i file `.mca` (VivaldiScore gzip-compresso).
/// Usiamo `UTType(filenameExtension:conformingTo:)` invece di `importedAs`
/// per evitare la richiesta di registrazione `UTImportedTypeDeclarations`
/// nell'Info.plist (che lo ScoreEditor non ha). SwiftUI accetta tipi derivati
/// da extension; se il sistema non riconosce "mca" come tipo registrato cade
/// su `public.data` (fallback corretto per file binari generici).
extension UTType {
    static var vivaldiMCA: UTType {
        UTType(filenameExtension: "mca", conformingTo: .data) ?? .data
    }
}

struct ContentView: View {
    @State private var manager = ScoreDocumentManager()
    @State private var selectedScore: VivaldiScore?
    @State private var showFileImporter = false
    @State private var showSaveAsExporter = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            if let score = selectedScore,
               let index = manager.scores.firstIndex(where: { $0.id == score.id }) {
                ScoreDetailView(score: $manager.scores[index], onChanged: { manager.isDirty = true })
            } else {
                emptyState
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json, .vivaldiMCA]) { result in
            switch result {
            case .success(let url):
                do {
                    _ = url.startAccessingSecurityScopedResource()
                    defer { url.stopAccessingSecurityScopedResource() }
                    try manager.loadFile(url)
                    selectedScore = manager.scores.first
                } catch {
                    errorMessage = error.localizedDescription
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .fileExporter(
            isPresented: $showSaveAsExporter,
            document: ScoreMCADocument(score: manager.scores.first),
            contentType: .vivaldiMCA,
            defaultFilename: manager.scores.first.map { $0.title.replacingOccurrences(of: "/", with: "-") } ?? "score"
        ) { result in
            switch result {
            case .success(let url):
                manager.currentFileURL = url
                manager.isDirty = false
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .alert("Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List(selection: $selectedScore) {
            if let pack = manager.packInfo, manager.isPack {
                Section("Pack: \(pack.title)") {
                    Text(pack.author).font(.caption).foregroundStyle(.secondary)
                }
            }

            Section("Scores (\(manager.scores.count))") {
                ForEach(manager.scores) { score in
                    scoreRow(score)
                        .tag(score)
                }
                .onDelete { manager.deleteScore(at: $0) }
            }
        }
        .navigationTitle("VivaldiScore Editor")
        #if os(macOS)
        .frame(minWidth: 260)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showFileImporter = true } label: {
                    Label("Open", systemImage: "folder")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button { manager.addNewScore(); selectedScore = manager.scores.last } label: {
                    Label("New Score", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    try? manager.save()
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .disabled(!manager.isDirty || manager.currentFileURL == nil)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showSaveAsExporter = true
                } label: {
                    Label("Save as MCA", systemImage: "archivebox")
                }
                .disabled(manager.scores.count != 1 || manager.isPack)
                .help("Save as compressed .mca (gzip JSON, 70-90% smaller)")
            }
        }
    }

    // MARK: - MCA file document wrapper for fileExporter

    /// Wrapper minimal-FileDocument per `.fileExporter`: serializza UN singolo
    /// VivaldiScore in formato `.mca`. Per pack/array si usa il classico Save
    /// JSON. Conform a `FileDocument` con readableContentTypes vuoto perché
    /// usiamo solo come writer.
    struct ScoreMCADocument: FileDocument {
        static var readableContentTypes: [UTType] { [.vivaldiMCA] }
        static var writableContentTypes: [UTType] { [.vivaldiMCA] }
        let score: VivaldiScore?

        init(score: VivaldiScore?) { self.score = score }

        init(configuration: ReadConfiguration) throws {
            // Non usato (apertura file passa per il fileImporter), ma richiesto
            // dal protocol. Tenta decode come MCA → score.
            if let data = configuration.file.regularFileContents,
               let s = VivaldiScore.fromMCA(data) {
                self.score = s
            } else {
                throw NSError(domain: "VivaldiScoreEditor", code: 4,
                              userInfo: [NSLocalizedDescriptionKey: "Cannot read MCA file"])
            }
        }

        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            guard let s = score, let data = s.toMCA() else {
                throw NSError(domain: "VivaldiScoreEditor", code: 5,
                              userInfo: [NSLocalizedDescriptionKey: "MCA encode failed"])
            }
            return FileWrapper(regularFileWithContents: data)
        }
    }

    private func scoreRow(_ score: VivaldiScore) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: score.scoreType == .rhythm ? "metronome" :
                        score.scoreType == .pitch ? "music.note" : "music.note.list")
                    .foregroundStyle(.orange)
                Text(score.title).fontWeight(.medium)
            }
            HStack(spacing: 8) {
                Text(score.scoreType.rawValue).font(.caption).foregroundStyle(.secondary)
                Text(score.effectiveClef.symbol).font(.caption)
                Text(score.timeSignature.displayString).font(.caption).foregroundStyle(.secondary)
                Text("\(score.bars.count) bars").font(.caption).foregroundStyle(.secondary)
                if score.metadata?.difficulty != nil {
                    Text("d\(score.metadata!.difficulty!)").font(.caption).foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("Open a VivaldiScore JSON file")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("or create a new score with +")
                .font(.callout)
                .foregroundStyle(.tertiary)
            Button("Open File...") { showFileImporter = true }
                .buttonStyle(.borderedProminent)
        }
    }
}
