import SwiftUI

// MARK: - Placed Event (pre-calculated position)

private struct PlacedEvent {
    let event: ScoreEvent
    let x: CGFloat
    let staffPos: Int
    let noteY: CGFloat
    let barIndex: Int
    let eventIndex: Int
    let flatIndex: Int // indice globale nell'intero score
}

/// Preview visuale dello score su pentagramma — engine multi-pass
struct ScoreStaffPreview: View {
    let score: VivaldiScore

    private let lineSpacing: CGFloat = 10
    private let staffLines = 5
    private let noteWidth: CGFloat = 13
    private let noteHeight: CGFloat = 9
    private let barSpacing: CGFloat = 24
    private let eventSpacing: CGFloat = 36
    private let stemLength: CGFloat = 35

    // MARK: - Layout calculations

    private var staffHeight: CGFloat { CGFloat(staffLines - 1) * lineSpacing }

    private func buildLayout() -> (placed: [PlacedEvent], barlineXs: [CGFloat], totalWidth: CGFloat, topMargin: CGFloat, totalHeight: CGFloat) {
        let clefWidth: CGFloat = 55
        let keySigWidth: CGFloat = score.keySignature.map { CGFloat(abs($0.fifths)) * lineSpacing * 0.85 + 12 } ?? 0
        var x = clefWidth + keySigWidth + 10
        var placed: [PlacedEvent] = []
        var barlineXs: [CGFloat] = []
        var flat = 0

        for (barIdx, bar) in score.bars.enumerated() {
            for (evIdx, event) in bar.events.enumerated() {
                let midi = event.isRest ? 67 : (event.pitch ?? 67)
                let sp = staffPosition(forMidi: midi)
                let topMarginTemp: CGFloat = 80 // placeholder, recalculated below
                let fLY = topMarginTemp + staffHeight
                let ny = fLY - CGFloat(sp) * (lineSpacing / 2.0)
                placed.append(PlacedEvent(event: event, x: x, staffPos: sp, noteY: ny, barIndex: barIdx, eventIndex: evIdx, flatIndex: flat))
                x += eventSpacing
                flat += 1
            }
            if barIdx < score.bars.count - 1 {
                barlineXs.append(x)
                x += barSpacing
            }
        }

        let tw = max(x + 40, 300)

        // Calculate margins from actual positions
        let notePositions = placed.filter { !$0.event.isRest }.map { $0.staffPos }
        let maxPos = notePositions.max() ?? 8
        let minPos = notePositions.min() ?? 0
        let topExtra = max(0, CGFloat(maxPos - 8)) * (lineSpacing / 2) + lineSpacing * 6
        let bottomExtra = max(0, CGFloat(-minPos)) * (lineSpacing / 2) + lineSpacing * 5
        let th = staffHeight + topExtra + bottomExtra
        let tm = topExtra

        // Recalculate noteY with correct topMargin
        let firstLineY = tm + staffHeight
        let corrected = placed.map { p -> PlacedEvent in
            let ny = firstLineY - CGFloat(p.staffPos) * (lineSpacing / 2.0)
            return PlacedEvent(event: p.event, x: p.x, staffPos: p.staffPos, noteY: ny, barIndex: p.barIndex, eventIndex: p.eventIndex, flatIndex: p.flatIndex)
        }

        return (corrected, barlineXs, tw, tm, th)
    }

    var body: some View {
        let layout = buildLayout()
        ScrollView(.horizontal, showsIndicators: true) {
            Canvas { context, size in
                let firstLineY = layout.topMargin + staffHeight

                // Pass 1: Staff lines
                for i in 0..<staffLines {
                    let y = firstLineY - CGFloat(i) * lineSpacing
                    var path = Path()
                    path.move(to: CGPoint(x: 20, y: y))
                    path.addLine(to: CGPoint(x: layout.totalWidth - 20, y: y))
                    context.stroke(path, with: .color(.gray.opacity(0.5)), lineWidth: 0.8)
                }

                // Pass 2: Clef (setticlavio-aware)
                let clef = score.effectiveClef
                let clefText = Text(clef.symbol).font(.system(size: lineSpacing * clef.symbolFontScale)).foregroundColor(.gray.opacity(0.7))
                let clefLineY = firstLineY - CGFloat(clef.symbolLineIndex) * lineSpacing
                context.draw(context.resolve(clefText), at: CGPoint(x: 38, y: clefLineY))

                // Pass 3: Key signature
                if let keySig = score.keySignature, keySig.fifths != 0 {
                    drawKeySignature(context: context, keySig: keySig, startX: 55, firstLineY: firstLineY)
                }

                // Pass 4: Barlines
                let topStaffY = firstLineY - CGFloat(staffLines - 1) * lineSpacing
                for bx in layout.barlineXs {
                    var bl = Path()
                    bl.move(to: CGPoint(x: bx, y: topStaffY))
                    bl.addLine(to: CGPoint(x: bx, y: firstLineY))
                    context.stroke(bl, with: .color(.gray.opacity(0.6)), lineWidth: 1)
                }
                // Final double barline
                if let lastP = layout.placed.last {
                    let endX = lastP.x + eventSpacing / 2
                    var thin = Path(); thin.move(to: CGPoint(x: endX, y: topStaffY)); thin.addLine(to: CGPoint(x: endX, y: firstLineY))
                    context.stroke(thin, with: .color(.gray.opacity(0.6)), lineWidth: 1)
                    var thick = Path(); thick.move(to: CGPoint(x: endX + 4, y: topStaffY)); thick.addLine(to: CGPoint(x: endX + 4, y: firstLineY))
                    context.stroke(thick, with: .color(.gray.opacity(0.6)), lineWidth: 3)
                }

                // Pass 5: Notes (heads, stems, ledger lines, dots) — NO flags for beamed notes
                let grouped = groupedEvents(layout.placed)
                for p in layout.placed {
                    if p.event.isRest {
                        drawRest(context: context, duration: p.event.duration, x: p.x, firstLineY: firstLineY)
                    } else {
                        let isBeamed = grouped[p.event.groupId ?? -1] != nil && p.event.duration.beamCount > 0
                        drawNoteHead(context: context, p: p, firstLineY: firstLineY, drawFlags: !isBeamed)
                    }
                }

                // Pass 6: Beams for any grouped notes with beamCount > 0 (mixed beaming supported)
                for (_, group) in grouped {
                    let notes = group.filter { !$0.event.isRest && $0.event.duration.beamCount > 0 }
                    guard notes.count >= 2 else { continue }
                    drawBeams(context: context, notes: notes, beamCount: 0, firstLineY: firstLineY)
                }

                // Pass 7: Brackets for groups where notes have NO beams (quarter or longer)
                // + Group number label for ALL non-beam groups
                for (_, group) in grouped {
                    let groupType = group.first?.event.groupType ?? .beam
                    guard groupType != .beam else { continue }
                    let num = groupType.groupNumber
                    let hasBeamedNotes = group.contains { !$0.event.isRest && $0.event.duration.beamCount > 0 }

                    if !hasBeamedNotes {
                        // Quarter-note groups: bracket ⌐___⌐ + number
                        drawGroupBracket(context: context, group: group, number: num, firstLineY: firstLineY)
                    } else {
                        // Eighth-note groups: just the number above/below the beam
                        drawGroupNumber(context: context, group: group, number: num, firstLineY: firstLineY)
                    }
                }

                // Pass 8: Ties (including cross-bar)
                for (i, p) in layout.placed.enumerated() {
                    guard p.event.tieToNext, !p.event.isRest else { continue }
                    let nextIndex = i + 1
                    guard nextIndex < layout.placed.count else { continue }
                    let next = layout.placed[nextIndex]
                    drawTie(context: context, from: p, to: next)
                }

                // Pass 8b: Slurs (legature di frase — arco su più note, anche cross-bar)
                for (i, p) in layout.placed.enumerated() {
                    guard let slurLen = p.event.slurLength, slurLen > 0, !p.event.isRest else { continue }
                    let endIndex = min(i + slurLen, layout.placed.count - 1)
                    guard endIndex > i else { continue }
                    let endP = layout.placed[endIndex]
                    drawSlur(context: context, from: p, to: endP, allBetween: Array(layout.placed[i...endIndex]))
                }

                // Pass 9: Pitch labels
                if score.scoreType != .rhythm {
                    for p in layout.placed where !p.event.isRest {
                        if let midi = p.event.pitch {
                            let label = Text(MidiHelper.noteName(midi)).font(.system(size: 8)).foregroundColor(.orange.opacity(0.8))
                            context.draw(context.resolve(label), at: CGPoint(x: p.x, y: firstLineY + lineSpacing * 2.5))
                        }
                    }
                }
            }
            .frame(width: layout.totalWidth, height: layout.totalHeight)
        }
        .frame(height: layout.totalHeight)
    }

    // MARK: - Group events by groupId

    private func groupedEvents(_ placed: [PlacedEvent]) -> [Int: [PlacedEvent]] {
        var groups: [Int: [PlacedEvent]] = [:]
        for p in placed {
            if let gid = p.event.groupId {
                groups[gid, default: []].append(p)
            }
        }
        return groups
    }

    // MARK: - Draw Note Head + Stem

    private func drawNoteHead(context: GraphicsContext, p: PlacedEvent, firstLineY: CGFloat, drawFlags: Bool) {
        let noteColor: Color = p.event.pitch != nil ? .orange : .primary
        let filled = p.event.duration.isFilledHead
        let rect = CGRect(x: p.x - noteWidth / 2, y: p.noteY - noteHeight / 2, width: noteWidth, height: noteHeight)

        // Ledger lines
        drawLedgerLines(context: context, staffPos: p.staffPos, x: p.x, firstLineY: firstLineY)

        // Head (rotated ellipse)
        context.drawLayer { ctx in
            ctx.translateBy(x: p.x, y: p.noteY)
            ctx.rotate(by: .degrees(-15))
            ctx.translateBy(x: -p.x, y: -p.noteY)
            if filled {
                ctx.fill(Path(ellipseIn: rect), with: .color(noteColor))
            } else {
                ctx.stroke(Path(ellipseIn: rect), with: .color(noteColor), lineWidth: 1.5)
            }
        }

        // Stem
        if p.event.duration.hasStem {
            let stemUp = p.staffPos < 4
            let stemX = stemUp ? p.x + noteWidth / 2 - 1 : p.x - noteWidth / 2 + 1
            let stemEndY = stemUp ? p.noteY - stemLength : p.noteY + stemLength
            var stemPath = Path()
            stemPath.move(to: CGPoint(x: stemX, y: p.noteY))
            stemPath.addLine(to: CGPoint(x: stemX, y: stemEndY))
            context.stroke(stemPath, with: .color(noteColor), lineWidth: 1.2)

            // Flags only for non-beamed notes
            if drawFlags && p.event.duration.beamCount > 0 {
                let flagDir: CGFloat = stemUp ? 1 : -1
                for f in 0..<p.event.duration.beamCount {
                    let fy = stemEndY + CGFloat(f) * lineSpacing * 0.8 * flagDir
                    var flag = Path()
                    flag.move(to: CGPoint(x: stemX, y: fy))
                    flag.addCurve(
                        to: CGPoint(x: stemX + 10, y: fy + 12 * flagDir),
                        control1: CGPoint(x: stemX + 5, y: fy),
                        control2: CGPoint(x: stemX + 10, y: fy + 6 * flagDir)
                    )
                    context.stroke(flag, with: .color(noteColor), lineWidth: 1.5)
                }
            }
        }

        // Dot
        if p.event.dotted {
            let dotX = p.x + noteWidth / 2 + 4
            let dotY = p.noteY - (p.staffPos % 2 == 0 ? lineSpacing / 4 : 0)
            context.fill(Path(ellipseIn: CGRect(x: dotX - 1.5, y: dotY - 1.5, width: 3, height: 3)), with: .color(noteColor))
        }
    }

    // MARK: - Draw Beams (mixed beaming: shared beams + partial beams)

    private func drawBeams(context: GraphicsContext, notes: [PlacedEvent], beamCount: Int, firstLineY: CGFloat) {
        guard notes.count >= 2 else { return }
        let stemUp = (notes.map(\.staffPos).reduce(0, +) / notes.count) < 4
        let beamColor: Color = notes.first?.event.pitch != nil ? .orange : .primary
        let beamSpacing = stemUp ? lineSpacing * 0.7 : -lineSpacing * 0.7

        func stemEnd(_ p: PlacedEvent) -> CGPoint {
            let stemX = stemUp ? p.x + noteWidth / 2 - 1 : p.x - noteWidth / 2 + 1
            let stemEndY = stemUp ? p.noteY - stemLength : p.noteY + stemLength
            return CGPoint(x: stemX, y: stemEndY)
        }

        let minBeams = notes.map(\.event.duration.beamCount).min() ?? 1
        let maxBeams = notes.map(\.event.duration.beamCount).max() ?? 1

        // Level 1: full beams across ALL notes (shared minimum)
        let firstEnd = stemEnd(notes.first!)
        let lastEnd = stemEnd(notes.last!)
        for b in 0..<minBeams {
            let offset = CGFloat(b) * beamSpacing
            var beam = Path()
            beam.move(to: CGPoint(x: firstEnd.x, y: firstEnd.y + offset))
            beam.addLine(to: CGPoint(x: lastEnd.x, y: lastEnd.y + offset))
            context.stroke(beam, with: .color(beamColor), lineWidth: 3)
        }

        // Level 2: partial beams for notes with more beams than the minimum
        guard maxBeams > minBeams else { return }
        for beamLevel in minBeams..<maxBeams {
            // Find consecutive runs of notes with beamCount > beamLevel
            var runStart: Int?
            for i in 0...notes.count {
                let hasBeam = i < notes.count && notes[i].event.duration.beamCount > beamLevel
                if hasBeam && runStart == nil {
                    runStart = i
                } else if !hasBeam, let start = runStart {
                    let end = i - 1
                    let offset = CGFloat(beamLevel) * beamSpacing
                    let startPt = stemEnd(notes[start])
                    let endPt = stemEnd(notes[end])
                    var beam = Path()
                    beam.move(to: CGPoint(x: startPt.x, y: startPt.y + offset))
                    beam.addLine(to: CGPoint(x: endPt.x, y: endPt.y + offset))
                    context.stroke(beam, with: .color(beamColor), lineWidth: 3)
                    runStart = nil
                }
            }
        }
    }

    // MARK: - Draw Group Bracket (for quarter-note groups: triplets, quintuplets, sextuplets, septuplets)

    private func drawGroupBracket(context: GraphicsContext, group: [PlacedEvent], number: Int, firstLineY: CGFloat) {
        let nonRest = group.filter { !$0.event.isRest }
        guard let first = group.first, let last = group.last else { return }
        let avgPos = nonRest.isEmpty ? 4 : nonRest.map(\.staffPos).reduce(0, +) / nonRest.count
        let above = avgPos < 4

        let bracketY: CGFloat
        if above {
            bracketY = (nonRest.map(\.noteY).min() ?? firstLineY) - stemLength - 8
        } else {
            bracketY = (nonRest.map(\.noteY).max() ?? firstLineY) + stemLength + 8
        }

        let startX = first.x - 4
        let endX = last.x + 4
        let hookLen: CGFloat = above ? 5 : -5

        // Bracket: ⌐___⌐ shape with gap for number
        let midX = (startX + endX) / 2
        let gapHalf: CGFloat = 8

        var bracketL = Path()
        bracketL.move(to: CGPoint(x: startX, y: bracketY + hookLen))
        bracketL.addLine(to: CGPoint(x: startX, y: bracketY))
        bracketL.addLine(to: CGPoint(x: midX - gapHalf, y: bracketY))
        context.stroke(bracketL, with: .color(.secondary), lineWidth: 1.2)

        var bracketR = Path()
        bracketR.move(to: CGPoint(x: midX + gapHalf, y: bracketY))
        bracketR.addLine(to: CGPoint(x: endX, y: bracketY))
        bracketR.addLine(to: CGPoint(x: endX, y: bracketY + hookLen))
        context.stroke(bracketR, with: .color(.secondary), lineWidth: 1.2)

        // Number label in the gap
        let label = Text("\(number)").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
        context.draw(context.resolve(label), at: CGPoint(x: midX, y: bracketY))
    }

    // MARK: - Draw Group Number (for beamed eighth-note groups)

    private func drawGroupNumber(context: GraphicsContext, group: [PlacedEvent], number: Int, firstLineY: CGFloat) {
        let nonRest = group.filter { !$0.event.isRest }
        guard let first = group.first, let last = group.last else { return }
        let avgPos = nonRest.isEmpty ? 4 : nonRest.map(\.staffPos).reduce(0, +) / nonRest.count
        let above = avgPos < 4

        let y: CGFloat
        if above {
            y = (nonRest.map(\.noteY).min() ?? firstLineY) - stemLength - 10
        } else {
            y = (nonRest.map(\.noteY).max() ?? firstLineY) + stemLength + 10
        }

        let label = Text("\(number)").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
        context.draw(context.resolve(label), at: CGPoint(x: (first.x + last.x) / 2, y: y))
    }

    // MARK: - Draw Tie (cross-bar aware, opposite side of stems)

    private func drawTie(context: GraphicsContext, from: PlacedEvent, to: PlacedEvent) {
        let noteColor: Color = from.event.pitch != nil ? .orange.opacity(0.7) : Color.primary.opacity(0.7)
        // Stems up (staffPos < 4) → tie below; stems down (staffPos >= 4) → tie above
        let stemUp = from.staffPos < 4
        let above = !stemUp // tie on opposite side of stem

        let startX = from.x + noteWidth / 2 + 2
        let endX = to.x - noteWidth / 2 - 2
        let tieY = from.noteY + (above ? -8 : 8)
        let cpY = tieY + (above ? -10 : 10)

        var tiePath = Path()
        tiePath.move(to: CGPoint(x: startX, y: tieY))
        tiePath.addQuadCurve(
            to: CGPoint(x: endX, y: tieY),
            control: CGPoint(x: (startX + endX) / 2, y: cpY)
        )
        context.stroke(tiePath, with: .color(noteColor), lineWidth: 1.2)
    }

    // MARK: - Draw Slur (legatura di frase — arco ampio su più note, opposto ai gambi)

    private func drawSlur(context: GraphicsContext, from: PlacedEvent, to: PlacedEvent, allBetween: [PlacedEvent]) {
        let nonRest = allBetween.filter { !$0.event.isRest }
        let avgPos = nonRest.isEmpty ? 4 : nonRest.map(\.staffPos).reduce(0, +) / nonRest.count
        // Stems up (avgPos < 4) → slur below; stems down (avgPos >= 4) → slur above
        let stemUp = avgPos < 4
        let above = !stemUp // slur on opposite side of stems

        let startX = from.x
        let endX = to.x

        // Start/end Y: above note heads (opposite stems)
        let startY = from.noteY + (above ? -(noteHeight / 2 + 4) : (noteHeight / 2 + 4))
        let endY = to.noteY + (above ? -(noteHeight / 2 + 4) : (noteHeight / 2 + 4))

        // Control point: follow the extreme note position on the slur side
        let midX = (startX + endX) / 2
        let extremeNoteY: CGFloat
        if above {
            extremeNoteY = (nonRest.map(\.noteY).min() ?? from.noteY) - noteHeight / 2 - 14
        } else {
            extremeNoteY = (nonRest.map(\.noteY).max() ?? from.noteY) + noteHeight / 2 + 14
        }

        var slurPath = Path()
        slurPath.move(to: CGPoint(x: startX, y: startY))
        slurPath.addCurve(
            to: CGPoint(x: endX, y: endY),
            control1: CGPoint(x: midX - (endX - startX) * 0.15, y: extremeNoteY),
            control2: CGPoint(x: midX + (endX - startX) * 0.15, y: extremeNoteY)
        )
        context.stroke(slurPath, with: .color(.primary.opacity(0.5)), lineWidth: 1.5)
    }

    // MARK: - Draw Rest

    private func drawRest(context: GraphicsContext, duration: RhythmDuration, x: CGFloat, firstLineY: CGFloat) {
        let line3Y = firstLineY - 2 * lineSpacing
        let line4Y = firstLineY - 3 * lineSpacing
        let restColor: Color = .gray

        switch duration {
        case .whole:
            context.fill(Path(CGRect(x: x - 6, y: line4Y, width: 12, height: lineSpacing / 2)), with: .color(restColor))
        case .half:
            context.fill(Path(CGRect(x: x - 6, y: line3Y - lineSpacing / 2, width: 12, height: lineSpacing / 2)), with: .color(restColor))
        case .quarter:
            var path = Path()
            let top = line4Y + 2; let bot = firstLineY - lineSpacing + 2; let mid = (top + bot) / 2
            path.move(to: CGPoint(x: x + 3, y: top))
            path.addLine(to: CGPoint(x: x - 4, y: mid - 4))
            path.addLine(to: CGPoint(x: x + 4, y: mid + 2))
            path.addLine(to: CGPoint(x: x - 3, y: bot))
            context.stroke(path, with: .color(restColor), lineWidth: 2.5)
        case .eighth, .triplet, .quarterTriplet:
            // Pallino nel 3° spazio (tra riga 3 e riga 4), codina scende al 2° spazio
            let space3Y = line3Y - lineSpacing / 2  // spazio tra riga 3 (B4) e riga 4 (D5)
            context.fill(Path(ellipseIn: CGRect(x: x - 2, y: space3Y - 2, width: 4, height: 4)), with: .color(restColor))
            var line = Path(); line.move(to: CGPoint(x: x, y: space3Y)); line.addLine(to: CGPoint(x: x - 5, y: line3Y + lineSpacing * 0.5))
            context.stroke(line, with: .color(restColor), lineWidth: 1.8)
        case .sixteenth:
            // Due pallini: 3° spazio e sotto, codina
            let space3Y = line3Y - lineSpacing / 2
            let dot2Y = space3Y + lineSpacing * 0.7
            context.fill(Path(ellipseIn: CGRect(x: x - 2, y: space3Y - 2, width: 4, height: 4)), with: .color(restColor))
            context.fill(Path(ellipseIn: CGRect(x: x - 2, y: dot2Y - 2, width: 4, height: 4)), with: .color(restColor))
            var line = Path(); line.move(to: CGPoint(x: x, y: space3Y)); line.addLine(to: CGPoint(x: x - 6, y: line3Y + lineSpacing))
            context.stroke(line, with: .color(restColor), lineWidth: 1.8)
        case .thirtySecond:
            // Tre pallini dal 3° spazio in giù
            let space3Y = line3Y - lineSpacing / 2
            let dot2Y = space3Y + lineSpacing * 0.6; let dot3Y = dot2Y + lineSpacing * 0.6
            for dy in [space3Y, dot2Y, dot3Y] { context.fill(Path(ellipseIn: CGRect(x: x - 2, y: dy - 2, width: 4, height: 4)), with: .color(restColor)) }
            var line = Path(); line.move(to: CGPoint(x: x, y: space3Y)); line.addLine(to: CGPoint(x: x - 7, y: line3Y + lineSpacing * 1.5))
            context.stroke(line, with: .color(restColor), lineWidth: 1.8)
        }
    }

    // MARK: - Ledger Lines

    private func drawLedgerLines(context: GraphicsContext, staffPos: Int, x: CGFloat, firstLineY: CGFloat) {
        let ledgerW: CGFloat = noteWidth + 8
        if staffPos < 0 {
            var pos = -2
            while pos >= staffPos { let y = firstLineY - CGFloat(pos) * (lineSpacing / 2.0); var p = Path(); p.move(to: CGPoint(x: x - ledgerW/2, y: y)); p.addLine(to: CGPoint(x: x + ledgerW/2, y: y)); context.stroke(p, with: .color(.gray.opacity(0.5)), lineWidth: 0.8); pos -= 2 }
        }
        if staffPos > 8 {
            var pos = 10
            while pos <= staffPos { let y = firstLineY - CGFloat(pos) * (lineSpacing / 2.0); var p = Path(); p.move(to: CGPoint(x: x - ledgerW/2, y: y)); p.addLine(to: CGPoint(x: x + ledgerW/2, y: y)); context.stroke(p, with: .color(.gray.opacity(0.5)), lineWidth: 0.8); pos += 2 }
        }
        if staffPos == -1 { let y = firstLineY - CGFloat(-2) * (lineSpacing / 2.0); var p = Path(); p.move(to: CGPoint(x: x - ledgerW/2, y: y)); p.addLine(to: CGPoint(x: x + ledgerW/2, y: y)); context.stroke(p, with: .color(.gray.opacity(0.5)), lineWidth: 0.8) }
    }

    // MARK: - Key Signature

    @discardableResult
    private func drawKeySignature(context: GraphicsContext, keySig: ScoreKeySignature, startX: CGFloat, firstLineY: CGFloat) -> CGFloat {
        let count = abs(keySig.fifths); guard count > 0 else { return 0 }
        let spacing: CGFloat = lineSpacing * 0.85; let fontSize = lineSpacing * 2.2
        let symbol = keySig.fifths > 0 ? "\u{266F}" : "\u{266D}"
        let clef = score.effectiveClef
        let positions = keySig.fifths > 0 ? clef.keySigSharpPositions : clef.keySigFlatPositions
        for i in 0..<min(count, 7) {
            let xPos = startX + CGFloat(i) * spacing; let sp = positions[i]
            let y = firstLineY - CGFloat(sp) * (lineSpacing / 2.0)
            let text = Text(symbol).font(.system(size: fontSize)).foregroundColor(.gray.opacity(0.7))
            context.draw(context.resolve(text), at: CGPoint(x: xPos, y: y))
        }
        return CGFloat(min(count, 7)) * spacing + 4
    }

    // MARK: - Staff Position (clef-aware)

    private func staffPosition(forMidi midi: Int) -> Int {
        let octave = midi / 12; let noteIndex = midi % 12
        let naturalPos: Int
        switch noteIndex {
        case 0: naturalPos = 0; case 1: naturalPos = 0; case 2: naturalPos = 1; case 3: naturalPos = 1
        case 4: naturalPos = 2; case 5: naturalPos = 3; case 6: naturalPos = 3; case 7: naturalPos = 4
        case 8: naturalPos = 4; case 9: naturalPos = 5; case 10: naturalPos = 5; case 11: naturalPos = 6
        default: naturalPos = 0
        }
        return octave * 7 + naturalPos - score.effectiveClef.staffOffset
    }
}
