import AppKit
import Foundation

guard CommandLine.arguments.count == 4 else {
    fatalError("usage: swift render_scene_overlay.swift CAPTION SOURCE OUT_PNG")
}
let caption = CommandLine.arguments[1]
let source = CommandLine.arguments[2]
let out = URL(fileURLWithPath: CommandLine.arguments[3])
let W: CGFloat = 1280, H: CGFloat = 720
let image = NSImage(size: NSSize(width: W, height: H))
image.lockFocus()
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: W, height: H).fill()

let panel = NSBezierPath(roundedRect: NSRect(x: 28, y: 510, width: 770, height: 175), xRadius: 14, yRadius: 14)
NSColor(calibratedRed: 0.015, green: 0.03, blue: 0.055, alpha: 0.72).setFill()
panel.fill()

func draw(_ value: String, rect: NSRect, size: CGFloat, weight: NSFont.Weight, color: NSColor) {
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .byWordWrapping
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: style
    ]
    (value as NSString).draw(in: rect, withAttributes: attrs)
}
let mint = NSColor(calibratedRed: 0.52, green: 0.92, blue: 0.80, alpha: 1)
draw(caption, rect: NSRect(x: 52, y: 562, width: 720, height: 100), size: 38, weight: .bold, color: .white)
draw(source, rect: NSRect(x: 55, y: 523, width: 700, height: 35), size: 20, weight: .medium, color: mint)

let badge = NSBezierPath(roundedRect: NSRect(x: 28, y: 22, width: 425, height: 46), xRadius: 9, yRadius: 9)
NSColor(calibratedRed: 0.01, green: 0.025, blue: 0.045, alpha: 0.76).setFill()
badge.fill()
draw("ILLUSTRATION · NOT SUNO UI", rect: NSRect(x: 46, y: 32, width: 390, height: 28), size: 20, weight: .semibold, color: .white)

image.unlockFocus()
guard let png = NSBitmapImageRep(data: image.tiffRepresentation!)?.representation(using: .png, properties: [:]) else {
    fatalError("PNG render failed")
}
try png.write(to: out)
