import AppKit
import Foundation
guard CommandLine.arguments.count == 2 else { fatalError("usage: swift render_label.swift OUT_PNG") }
let image = NSImage(size: NSSize(width: 1280, height: 720))
image.lockFocus()
NSColor.clear.setFill(); NSRect(x: 0, y: 0, width: 1280, height: 720).fill()
let box = NSBezierPath(roundedRect: NSRect(x: 31, y: 24, width: 425, height: 46), xRadius: 10, yRadius: 10)
NSColor(calibratedRed: 0.01, green: 0.03, blue: 0.06, alpha: 0.72).setFill(); box.fill()
let text = NSAttributedString(string: "ILLUSTRATION · NOT SUNO UI", attributes: [
    .font: NSFont.systemFont(ofSize: 20, weight: .semibold),
    .foregroundColor: NSColor.white,
    .kern: 1
])
text.draw(at: NSPoint(x: 49, y: 34))
image.unlockFocus()
let data = NSBitmapImageRep(data: image.tiffRepresentation!)!.representation(using: .png, properties: [:])!
try data.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
