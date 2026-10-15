import AppKit
import Foundation

// Original, explicitly illustrative motion-graphic cards for episode 1.
// Usage: swift render_explainer_card.swift KIND TITLE SUBTITLE SOURCE OUT.png
guard CommandLine.arguments.count == 6 else {
    fatalError("usage: swift render_explainer_card.swift KIND TITLE SUBTITLE SOURCE OUT")
}
let kind = CommandLine.arguments[1]
let title = CommandLine.arguments[2]
let subtitle = CommandLine.arguments[3]
let source = CommandLine.arguments[4]
let out = URL(fileURLWithPath: CommandLine.arguments[5])
let W: CGFloat = 1280, H: CGFloat = 720

func color(_ hex: UInt32, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: alpha)
}
let bg = color(0x081720)
let panel = color(0x102833)
let cream = color(0xF6F0E6)
let pale = color(0xB8C9C9)
let mint = color(0x8EE1C9)
let amber = color(0xF4B56A)
let coral = color(0xF18476)
let grid = color(0x32505B)

func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat,
         _ fill: NSColor, radius: CGFloat = 12, stroke: NSColor? = nil, lineWidth: CGFloat = 2) {
    let p = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: radius, yRadius: radius)
    fill.setFill(); p.fill()
    if let s = stroke { s.setStroke(); p.lineWidth = lineWidth; p.stroke() }
}
func line(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat,
          _ c: NSColor, width: CGFloat = 2, dash: [CGFloat] = []) {
    let p = NSBezierPath(); p.move(to: NSPoint(x: x1, y: y1)); p.line(to: NSPoint(x: x2, y: y2))
    p.lineWidth = width; p.lineCapStyle = .round
    if !dash.isEmpty { p.setLineDash(dash, count: dash.count, phase: 0) }
    c.setStroke(); p.stroke()
}
func text(_ s: String, _ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat,
          size: CGFloat = 28, weight: NSFont.Weight = .regular, c: NSColor = cream,
          align: NSTextAlignment = .left) {
    let p = NSMutableParagraphStyle(); p.alignment = align; p.lineBreakMode = .byWordWrapping
    let a: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: c, .paragraphStyle: p
    ]
    (s as NSString).draw(in: NSRect(x: x, y: y, width: w, height: h), withAttributes: a)
}
func circle(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat, _ c: NSColor) {
    c.setFill(); NSBezierPath(ovalIn: NSRect(x: x-r, y: y-r, width: r*2, height: r*2)).fill()
}
func arrow(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat, _ c: NSColor, width: CGFloat = 4) {
    line(x1,y1,x2,y2,c,width:width)
    let angle = atan2(y2-y1,x2-x1)
    let len: CGFloat = 15
    line(x2,y2,x2-len*cos(angle-0.45),y2-len*sin(angle-0.45),c,width:width)
    line(x2,y2,x2-len*cos(angle+0.45),y2-len*sin(angle+0.45),c,width:width)
}
func waveform(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ c: NSColor, taper: Bool = false) {
    let n = 78
    for i in 0..<n {
        let t = CGFloat(i) / CGFloat(n-1)
        let amp = abs(sin(t * 19.7) * cos(t * 8.3)) * 0.58 + 0.16
        let fade = taper ? pow(1-t, 1.6) : 1
        let bar = max(3, h * amp * fade)
        box(x + t*w, y + (h-bar)/2, 5, bar, c, radius: 2)
    }
}
func timeline(_ mode: String) {
    let x: CGFloat = 115, y: CGFloat = 230, w: CGFloat = 1050, h: CGFloat = 220
    box(x,y,w,h,panel,radius:18,stroke:grid)
    let barW = w/4
    for i in 0...4 {
        let xx = x + CGFloat(i)*barW
        line(xx,y+22,xx,y+h-22,i == 0 ? amber : grid,width:i == 0 ? 4 : 2)
        if i < 4 { text("BAR \(i+1)", xx+12,y+h-45,barW-20,27,size:16,weight:.semibold,c:pale) }
    }
    text("YOUR FOUR-BAR MELODY",x+20,y+h+18,w-40,28,size:17,weight:.bold,c:pale)
    let noteY = y+155
    for (i,v) in [0,2,1,3,2,1,2,0,3,2,1,0].enumerated() {
        let xx = x+50+CGFloat(i)*80
        circle(xx,noteY+CGFloat(v)*10,8,mint)
        line(xx+8,noteY+CGFloat(v)*10,xx+8,noteY+CGFloat(v)*10+28,mint,width:3)
    }
    let clipY=y+45
    if mode == "melody" { return }
    if mode == "late" || mode == "beat" || mode == "ghost" || mode == "compare" {
        box(x+120,clipY,620,64,coral.withAlphaComponent(0.21),radius:9,stroke:coral)
        waveform(x+145,clipY+10,555,44,coral)
        text("CURRENT CLIP — LATE",x+475,clipY+69,350,25,size:16,weight:.bold,c:coral)
        if mode == "beat" || mode == "ghost" || mode == "compare" {
            line(x+30,y+25,x+30,y+h-25,amber,width:5)
            text("BEAT 1",x+20,y+5,160,25,size:16,weight:.bold,c:amber)
        }
        if mode == "ghost" || mode == "compare" {
            box(x+30,clipY-95,620,64,mint.withAlphaComponent(0.10),radius:9,stroke:mint,lineWidth:2)
            waveform(x+55,clipY-85,555,44,mint.withAlphaComponent(0.7))
            text("POSSIBLE NEW TAKE — UNTESTED",x+680,clipY-78,335,45,size:18,weight:.bold,c:mint)
        }
        return
    }
    let clipW: CGFloat = mode == "short" ? 480 : 710
    box(x+30,clipY,clipW,64,mint.withAlphaComponent(0.16),radius:9,stroke:mint)
    waveform(x+55,clipY+10,clipW-70,44,mint,taper:mode == "fadeA" || mode == "fadeB")
    if mode == "short" { arrow(x+530,clipY+32,x+895,clipY+32,amber) }
    if mode == "stretch" || mode == "fill" {
        line(x+30+clipW,clipY-10,x+30+clipW,clipY+75,amber,width:5)
        arrow(x+30+clipW+15,clipY+32,x+945,clipY+32,amber)
        text("SHIFT + DRAG",x+765,clipY+76,230,30,size:18,weight:.bold,c:amber)
    }
    if mode == "hard" { line(x+30+clipW,clipY,x+30+clipW,clipY+64,coral,width:6) }
    if mode == "fadeA" || mode == "fadeB" {
        let p = NSBezierPath(); p.move(to:NSPoint(x:x+30+clipW-180,y:clipY+60))
        if mode == "fadeA" { p.curve(to:NSPoint(x:x+30+clipW,y:clipY+5), controlPoint1:NSPoint(x:x+30+clipW-55,y:clipY+60),controlPoint2:NSPoint(x:x+30+clipW-75,y:clipY+4)) }
        else { p.curve(to:NSPoint(x:x+30+clipW,y:clipY+5),controlPoint1:NSPoint(x:x+30+clipW-160,y:clipY+15),controlPoint2:NSPoint(x:x+30+clipW-20,y:clipY+15)) }
        p.lineWidth=6; amber.setStroke(); p.stroke()
        text(mode == "fadeA" ? "CURVE A" : "CURVE B",x+830,clipY+17,170,35,size:19,weight:.bold,c:amber)
    }
}
func decision() {
    box(115,235,455,215,panel,radius:18,stroke:coral)
    box(710,235,455,215,panel,radius:18,stroke:mint)
    text("REGENERATE",155,365,375,50,size:31,weight:.bold,c:coral)
    text("Replace the whole idea",155,292,370,40,size:23,c:pale)
    text("KEEP + EDIT",750,365,375,50,size:31,weight:.bold,c:mint)
    text("Change just the clip",750,292,370,40,size:23,c:pale)
    text("OR",602,318,78,45,size:27,weight:.bold,c:amber,align:.center)
}
func listen() {
    box(120,210,1040,240,panel,radius:18,stroke:grid)
    waveform(185,332,900,80,mint)
    line(160,280,1120,280,grid,width:2)
    text("LISTENING CHECK",175,235,360,35,size:22,weight:.bold,c:amber)
    text("No sound-quality result is shown here.",490,227,625,55,size:25,c:cream,align:.right)
}
func windows(_ comparison: Bool) {
    box(120,210,1040,260,panel,radius:18,stroke:grid)
    let labels=["SYNTH","MUSICAL TYPING","PLUG-INS"]
    for i in 0..<3 {
        let xx:CGFloat = 160+CGFloat(i)*330
        box(xx,280,290,135,i == 1 ? mint.withAlphaComponent(0.14) : color(0x1B3944),radius:12,stroke:i == 1 ? mint : grid)
        box(xx,385,290,30,color(0x284A55),radius:8)
        circle(xx+20,400,5,coral);circle(xx+38,400,5,amber);circle(xx+56,400,5,mint)
        text(labels[i],xx+20,322,250,45,size:22,weight:.semibold,c:cream,align:.center)
    }
    if comparison {
        text("WORKSPACE",210,217,360,42,size:23,weight:.bold,c:mint,align:.center)
        text("≠",605,215,70,46,size:32,weight:.bold,c:amber,align:.center)
        text("CLIP FIX",710,217,360,42,size:23,weight:.bold,c:coral,align:.center)
    }
}
func sourceCards(_ mode: String) {
    let both=mode == "fork" || mode == "converge" || mode == "limits"
    let left=mode != "sample"
    let right=mode != "stems" && mode != "clean"
    if left {
        box(110,225,both ? 505 : 1060,235,panel,radius:18,stroke:mint)
        text("ON A CREATIVE JOURNEY",145,402,both ? 435 : 990,38,size:20,weight:.bold,c:mint)
        text(mode == "clean" ? "Noise → tone → dynamics" : "Five separate stems",145,335,both ? 435 : 990,55,size:30,weight:.bold,c:cream)
        if mode == "stems" || mode == "clean" {
            for i in 0..<5 {
                let yy:CGFloat=248+CGFloat(i)*15
                box(158,yy,710,13,[mint,amber,coral,mint,amber][i].withAlphaComponent(0.65),radius:5)
            }
        } else { text("Reported editing workflow",145,265,both ? 435 : 990,45,size:22,c:pale) }
    }
    if right {
        box(both ? 665 : 110,225,both ? 505 : 1060,235,panel,radius:18,stroke:amber)
        let xx:CGFloat=both ? 700 : 145
        text("TODD EDWARDS",xx,402,both ? 435 : 990,38,size:20,weight:.bold,c:amber)
        text("Sampling generated material",xx,325,both ? 435 : 990,85,size:30,weight:.bold,c:cream)
        text("Reported production practice",xx,265,both ? 435 : 990,45,size:22,c:pale)
    }
    if mode == "converge" { arrow(400,215,635,162,mint); arrow(875,215,645,162,amber); text("EDIT AFTER GENERATION",290,106,700,45,size:29,weight:.bold,c:cream,align:.center) }
    if mode == "limits" { box(175,145,930,60,color(0x53342D),radius:12);text("Neither account tests the October 8 controls",205,157,870,37,size:24,weight:.bold,c:cream,align:.center) }
}
func evidence() {
    box(110,320,505,160,panel,radius:17,stroke:mint)
    box(665,320,505,160,panel,radius:17,stroke:amber)
    text("RELEASE NOTE",145,428,430,32,size:20,weight:.bold,c:mint)
    text("Controls announced",145,355,430,55,size:30,weight:.bold,c:cream)
    text("CREATOR ACCOUNTS",700,428,430,32,size:20,weight:.bold,c:amber)
    text("Editing can matter",700,355,430,55,size:30,weight:.bold,c:cream)
    box(235,190,810,75,color(0x53342D),radius:12)
    text("Neither proves a better finished song",260,207,760,45,size:28,weight:.bold,c:cream,align:.center)
}
func steps() {
    let labels=["1  CHECK ENTRANCE","2  STRETCH PHRASE","3  SHAPE EXIT"]
    for i in 0..<3 {
        let xx:CGFloat=105+CGFloat(i)*365
        box(xx,245,330,175,panel,radius:17,stroke:[mint,amber,coral][i])
        text(labels[i],xx+23,341,284,53,size:23,weight:.bold,c:[mint,amber,coral][i])
        waveform(xx+25,273,270,45,[mint,amber,coral][i])
    }
}
func versions() {
    for i in 0..<2 {
        let xx:CGFloat=110+CGFloat(i)*555
        box(xx,235,505,230,panel,radius:18,stroke:i == 0 ? amber : mint)
        text(i == 0 ? "ORIGINAL" : "ONE EDIT",xx+30,407,445,38,size:21,weight:.bold,c:i == 0 ? amber : mint)
        waveform(xx+40,285,425,80,i == 0 ? amber : mint)
    }
    arrow(625,347,655,347,cream,width:3)
}

let img=NSImage(size:NSSize(width:W,height:H)); img.lockFocus()
bg.setFill(); NSRect(x:0,y:0,width:W,height:H).fill()
for i in 0..<20 { line(0,CGFloat(i)*42,W,CGFloat(i)*42,color(0x15303A,0.32),width:1) }
for i in 0..<30 { line(CGFloat(i)*44,0,CGFloat(i)*44,H,color(0x15303A,0.26),width:1) }
if kind == "photo" {
    let path=URL(fileURLWithPath:CommandLine.arguments[5]).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("episode01_studio_plate.png").path
    if let photo=NSImage(contentsOfFile:path) {
        photo.draw(in:NSRect(x:0,y:0,width:W,height:H),
                   from:NSRect(origin:.zero,size:photo.size),operation:.sourceOver,fraction:0.45)
    }
    box(70,180,830,270,color(0x071720,0.80),radius:18)
}
text("SUNO IN PRACTICE  /  EPISODE 01",70,652,770,31,size:18,weight:.bold,c:mint)
text(title,70,557,1135,82,size:46,weight:.bold,c:cream)
text(subtitle,72,505,1120,42,size:22,c:pale)
switch kind {
case "photo": text("A songwriter’s decision, not a product demo",105,300,780,95,size:36,weight:.semibold,c:cream)
case "melody","late","beat","ghost","compare","short","stretch","fill","hard","fadeA","fadeB": timeline(kind)
case "choice": decision()
case "listen": listen()
case "windows": windows(false)
case "workspace": windows(true)
case "fork","stems","clean","sample","converge","limits": sourceCards(kind)
case "recap","steps": steps()
case "version","ab": versions()
case "evidence": evidence()
default: break
}
box(70,27,300,38,color(0x0E2530,0.9),radius:7)
text("ILLUSTRATION · NOT SUNO UI",84,37,275,24,size:15,weight:.bold,c:cream)
text(source,385,36,820,27,size:17,weight:.medium,c:pale,align:.right)
img.unlockFocus()
guard let data=NSBitmapImageRep(data:img.tiffRepresentation!)?.representation(using:.png,properties:[:]) else { fatalError("PNG failed") }
try data.write(to:out)
