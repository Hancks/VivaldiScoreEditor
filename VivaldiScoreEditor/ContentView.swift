import SwiftUI

struct ContentView: View {
    @State private var manager = ScoreDocumentManager()
    @State private var selectedScore: VivaldiScore?
    @State private var showFileImporter = false
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
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
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
                Text(score.timeSignature.displayString).font(.caption).foregroundStyle(.secondary)
                Text("\(score.bars.count) bars").font(.caption).foregroundStyle(.secondary)
                Text("\(score.totalNotes) notes").font(.caption).foregroundStyle(.secondary)
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

// MARK: - Make VivaldiScore Hashable for selection

extension VivaldiScore: Hashable {
    static func == (lhs: VivaldiScore, rhs: VivaldiScore) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
