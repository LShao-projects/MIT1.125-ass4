import AppKit
import Foundation

guard CommandLine.arguments.count == 3 || CommandLine.arguments.count == 7 else {
    fatalError("usage: swift render_style_frame.swift PHOTO OUT_PNG [EPISODE TITLE SUBTITLE LABEL]")
}
guard let photo = NSImage(contentsOfFile: CommandLine.arguments[1]) else { fatalError("photo unavailable") }
let out = URL(fileURLWithPath: CommandLine.arguments[2])
let episode = CommandLine.arguments.count == 7 ? CommandLine.arguments[3] : "01"
let title = CommandLine.arguments.count == 7 ? CommandLine.arguments[4].replacingOccurrences(of: "\\n", with: "\n") : "Keep it, or\nstart over?"
let subtitle = CommandLine.arguments.count == 7 ? CommandLine.arguments[5] : "A songwriter's guide to Suno Studio's new editing controls"
let footer = CommandLine.arguments.count == 7 ? CommandLine.arguments[6] : "ILLUSTRATIVE SCENE  •  OCTOBER 2026"
let W: CGFloat = 1920, H: CGFloat = 1080
let canvas = NSImage(size: NSSize(width: W, height: H))
canvas.lockFocus()
photo.draw(in: NSRect(x: 0, y: 0, width: W, height: H),
           from: NSRect(origin: .zero, size: photo.size), operation: .copy, fraction: 1)

let shade = NSGradient(colorsAndLocations:
    (NSColor(calibratedRed: 0.02, green: 0.04, blue: 0.08, alpha: 0.92), 0.0),
    (NSColor(calibratedRed: 0.02, green: 0.04, blue: 0.08, alpha: 0.55), 0.34),
    (NSColor(calibratedRed: 0.02, green: 0.04, blue: 0.08, alpha: 0.0), 0.72))!
shade.draw(in: NSRect(x: 0, y: 0, width: W, height: H), angle: 0)

func label(_ string: String, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat,
           size: CGFloat, color: NSColor, weight: NSFont.Weight = .regular, kern: CGFloat = 0) {
    let style = NSMutableParagraphStyle(); style.lineBreakMode = .byWordWrapping
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: style,
        .kern: kern
    ]
    (string as NSString).draw(in: NSRect(x: x, y: y, width: w, height: h), withAttributes: attrs)
}
let white = NSColor(calibratedWhite: 0.98, alpha: 1)
let mint = NSColor(calibratedRed: 0.51, green: 0.91, blue: 0.79, alpha: 1)
label("SUNO IN PRACTICE     /     EPISODE \(episode)", x: 130, y: 940, w: 890, h: 50,
      size: 27, color: mint, weight: .semibold, kern: 3)
let accent = NSBezierPath(roundedRect: NSRect(x: 130, y: 887, width: 115, height: 7), xRadius: 3, yRadius: 3)
mint.setFill(); accent.fill()
label(title, x: 125, y: 380, w: 1000, h: 400,
      size: 108, color: white, weight: .bold, kern: -3)
label(subtitle, x: 133, y: 285, w: 1000, h: 100,
      size: 36, color: NSColor(calibratedWhite: 0.92, alpha: 1), weight: .medium)
label(footer, x: 134, y: 110, w: 900, h: 44,
      size: 22, color: NSColor(calibratedWhite: 0.76, alpha: 1), weight: .medium, kern: 1)
canvas.unlockFocus()
guard let bitmap = NSBitmapImageRep(data: canvas.tiffRepresentation!),
      let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("PNG render failed") }
try png.write(to: out)
