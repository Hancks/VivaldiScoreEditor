import SwiftUI

/// Piccola icona nota musicale disegnata con Canvas — sempre renderizzata correttamente
struct NoteIconView: View {
    let duration: RhythmDuration
    let isRest: Bool
    var color: Color = .primary
    var size: CGFloat = 22

    var body: some View {
        Canvas { context, canvasSize in
            let cx = canvasSize.width / 2
            let cy = canvasSize.height / 2

            if isRest {
                drawRestIcon(context: context, cx: cx, cy: cy, size: canvasSize)
            } else {
                drawNoteIcon(context: context, cx: cx, cy: cy, size: canvasSize)
            }
        }
        .frame(width: size, height: size)
    }

    private func drawNoteIcon(context: GraphicsContext, cx: CGFloat, cy: CGFloat, size: CGSize) {
        let headW: CGFloat = size.width * 0.45
        let headH: CGFloat = size.height * 0.28
        let headY = size.height * 0.7
        let headRect = CGRect(x: cx - headW / 2, y: headY - headH / 2, width: headW, height: headH)

        // Note head (rotated ellipse)
        context.drawLayer { ctx in
            ctx.translateBy(x: cx, y: headY)
            ctx.rotate(by: .degrees(-15))
            ctx.translateBy(x: -cx, y: -headY)

            if duration.isFilledHead {
                ctx.fill(Path(ellipseIn: headRect), with: .color(color))
            } else {
                ctx.stroke(Path(ellipseIn: headRect), with: .color(color), lineWidth: 1.5)
            }
        }

        // Stem
        if duration.hasStem {
            let stemX = cx + headW / 2 - 1
            var stem = Path()
            stem.move(to: CGPoint(x: stemX, y: headY))
            stem.addLine(to: CGPoint(x: stemX, y: size.height * 0.12))
            context.stroke(stem, with: .color(color), lineWidth: 1.2)

            // Flags
            let flagCount = duration.beamCount
            if flagCount > 0 {
                for f in 0..<flagCount {
                    let flagY = size.height * 0.12 + CGFloat(f) * 5
                    var flag = Path()
                    flag.move(to: CGPoint(x: stemX, y: flagY))
                    flag.addCurve(
                        to: CGPoint(x: stemX + 7, y: flagY + 8),
                        control1: CGPoint(x: stemX + 4, y: flagY),
                        control2: CGPoint(x: stemX + 7, y: flagY + 4)
                    )
                    context.stroke(flag, with: .color(color), lineWidth: 1.3)
                }
            }
        }
    }

    private func drawRestIcon(context: GraphicsContext, cx: CGFloat, cy: CGFloat, size: CGSize) {
        let restColor = Color.gray
        switch duration {
        case .whole:
            // Filled rectangle
            let rect = CGRect(x: cx - 5, y: cy - 1, width: 10, height: 4)
            context.fill(Path(rect), with: .color(restColor))
            // Line above
            var line = Path()
            line.move(to: CGPoint(x: cx - 6, y: cy - 1))
            line.addLine(to: CGPoint(x: cx + 6, y: cy - 1))
            context.stroke(line, with: .color(restColor), lineWidth: 0.8)
        case .half:
            // Filled rectangle sitting on line
            let rect = CGRect(x: cx - 5, y: cy - 3, width: 10, height: 4)
            context.fill(Path(rect), with: .color(restColor))
            var line = Path()
            line.move(to: CGPoint(x: cx - 6, y: cy + 1))
            line.addLine(to: CGPoint(x: cx + 6, y: cy + 1))
            context.stroke(line, with: .color(restColor), lineWidth: 0.8)
        case .quarter:
            // Zig-zag
            var path = Path()
            path.move(to: CGPoint(x: cx + 2, y: cy - 7))
            path.addLine(to: CGPoint(x: cx - 3, y: cy - 1))
            path.addLine(to: CGPoint(x: cx + 3, y: cy + 2))
            path.addLine(to: CGPoint(x: cx - 2, y: cy + 8))
            context.stroke(path, with: .color(restColor), lineWidth: 2)
        default:
            // Dot + line for eighth and smaller
            context.fill(Path(ellipseIn: CGRect(x: cx - 2, y: cy - 4, width: 4, height: 4)), with: .color(restColor))
            var line = Path()
            line.move(to: CGPoint(x: cx, y: cy - 2))
            line.addLine(to: CGPoint(x: cx - 4, y: cy + 6))
            context.stroke(line, with: .color(restColor), lineWidth: 1.5)
        }
    }
}
