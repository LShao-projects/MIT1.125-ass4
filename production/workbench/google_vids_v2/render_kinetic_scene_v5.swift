import AppKit
import Foundation

// Episode 1 visual revision: retain only yellow lines that mark a real edit target.
// Original animated diagrams, rendered as silent footage. Never presents a real Suno UI.
// Compile: swiftc render_kinetic_scene.swift -o /private/tmp/ass4-kinetic
// Run: /private/tmp/ass4-kinetic SCENE FPS > rgba.raw
let scene = Int(CommandLine.arguments[1])!
let fps = Int(CommandLine.arguments[2])!
let durations: [Double] = [27, 30, 29, 28, 11, 44, 52]
let duration = durations[scene - 1]
let W = 1280, H = 720
let bg = 0x07151D, panel = 0x102630, panel2 = 0x193542
let cream = 0xF5F1E8, pale = 0xB7CAD0, mint = 0x84DEC5, amber = 0xF4B766, coral = 0xEB867A, grid = 0x385461

func c(_ hex: Int, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: CGFloat((hex >> 16) & 255)/255,
            green: CGFloat((hex >> 8) & 255)/255,
            blue: CGFloat(hex & 255)/255, alpha: alpha)
}
func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ hex: Int,
          _ radius: CGFloat = 0, _ alpha: CGFloat = 1, _ stroke: Int? = nil) {
    let path = NSBezierPath(roundedRect: NSRect(x:x,y:y,width:w,height:h),xRadius:radius,yRadius:radius)
    c(hex,alpha).setFill();path.fill()
    if let s=stroke { c(s).setStroke();path.lineWidth=1.5;path.stroke() }
}
func line(_ x1: CGFloat,_ y1: CGFloat,_ x2: CGFloat,_ y2: CGFloat,_ hex: Int,_ width: CGFloat = 2,_ alpha: CGFloat = 1) {
    let p=NSBezierPath();p.move(to:NSPoint(x:x1,y:y1));p.line(to:NSPoint(x:x2,y:y2))
    p.lineWidth=width;p.lineCapStyle = .round;c(hex,alpha).setStroke();p.stroke()
}
func label(_ s:String,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat,_ size:CGFloat=20,_ hex:Int=cream,_ bold:Bool=false) {
    let para=NSMutableParagraphStyle();para.lineBreakMode = .byTruncatingTail
    let at:[NSAttributedString.Key:Any] = [.font:NSFont.systemFont(ofSize:size,weight:bold ? .semibold : .regular),
                                          .foregroundColor:c(hex),.paragraphStyle:para]
    (s as NSString).draw(in:NSRect(x:x,y:y,width:w,height:h),withAttributes:at)
}
func ease(_ x:Double) -> CGFloat { let z=max(0,min(1,x));return CGFloat(z*z*(3-2*z)) }
func ramp(_ t:Double,_ a:Double,_ b:Double) -> CGFloat { ease((t-a)/(b-a)) }
func wav(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat,_ hex:Int,_ seed:CGFloat=0,_ fade:CGFloat=0) {
    let n=65
    for i in 0..<n {
        let u=CGFloat(i)/CGFloat(n-1)
        let amp=(0.22 + 0.55*abs(sin(u*19.7+seed)*cos(u*8.2+seed*0.4))) * (1-fade*u)
        rect(x+u*width,y+(height-height*amp)/2,max(3,width/CGFloat(n)-2),height*amp,hex,2)
    }
}
func chrome(_ t:Double,_ title:String,_ sub:String,_ source:String) {
    rect(0,0,1280,720,bg)
    rect(0,654,1280,66,panel)
    for i in 0..<3 { rect(22+CGFloat(i)*22,680,10,10,[coral,amber,mint][i],5) }
    label("STUDIO / EDIT SESSION",105,674,400,27,17,cream,true)
    label("ILLUSTRATION · NOT SUNO UI",989,674,270,25,14,pale,true)
    label(title,54,580,1160,62,39,cream,true)
    label(sub,56,545,1120,33,20,pale)
    rect(0,0,1280,53,panel)
    label(source,46,15,1100,26,16,pale)
    let pw=CGFloat(t/duration)*1280
    rect(0,0,pw,4,mint)
}
func timelineBase() {
    rect(54,192,1172,319,panel,14,1,grid)
    rect(54,473,1172,38,panel2,12)
    for i in 0...8 {
        let x:CGFloat=205+CGFloat(i)*119
        line(x,204,x,505,i%2 == 0 ? grid : panel2,i%2 == 0 ? 2 : 1)
        if i<8 {label("\(i/2+1).\(i%2 == 0 ? 1 : 3)",x+7,478,95,25,15,pale)}
    }
    label("MELODY",73,397,124,28,17,mint,true)
    label("TAKE",73,294,124,28,17,amber,true)
}
func melody(_ t:Double) {
    let seq:[CGFloat]=[0,2,1,3,2,0,2,3,1,2,1,0]
    for i in 0..<seq.count {
        let x=225+CGFloat(i)*77
        let y=403+seq[i]*11
        let on=Double(i)/Double(seq.count)*4.5 < t
        rect(x,y,49,8,on ? mint : grid,4)
    }
}
func clip(_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ color:Int,_ name:String,_ selected:Bool=false,_ fade:CGFloat=0) {
    rect(x,y,w,67,color,8,0.22,selected ? amber : color)
    wav(x+11,y+9,max(30,w-22),47,color,0.5,fade)
    label(name,x+9,y+70,w-9,22,15,color,true)
}
func cursor(_ x:CGFloat,_ y:CGFloat) {
    let p=NSBezierPath();p.move(to:NSPoint(x:x,y:y));p.line(to:NSPoint(x:x+4,y:y-24));p.line(to:NSPoint(x:x+11,y:y-17));p.line(to:NSPoint(x:x+18,y:y-32));p.line(to:NSPoint(x:x+24,y:y-29));p.line(to:NSPoint(x:x+17,y:y-15));p.line(to:NSPoint(x:x+28,y:y-15));p.close()
    c(cream).setFill();p.fill();c(bg).setStroke();p.lineWidth=2;p.stroke()
}
func fader(_ x:CGFloat,_ y:CGFloat,_ amount:CGFloat,_ color:Int) {
    rect(x,y,13,113,grid,6);rect(x-11,y+amount*105,35,20,color,6)
}
func gainGraph(_ x:CGFloat,_ y:CGFloat,_ variant:Int,_ progress:CGFloat) {
    rect(x,y,370,175,panel2,13)
    for i in 0...4 { line(x+20,y+25+CGFloat(i)*30,x+350,y+25+CGFloat(i)*30,grid,1) }
    let p=NSBezierPath();p.move(to:NSPoint(x:x+22,y:y+144))
    let endpoint=x+22+328*progress
    for i in 0...80 {
        let u=CGFloat(i)/80
        let xx=x+22+328*u
        if xx>endpoint {break}
        let yy=y+35+109*(variant==0 ? pow(1-u,2.3) : pow(1-u,0.48))
        p.line(to:NSPoint(x:xx,y:yy))
    }
    p.lineWidth=5;c(variant==0 ? mint : amber).setStroke();p.stroke()
}
func sourceTag(_ s:String,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ color:Int) {
    rect(x,y,w,35,color,7,0.13,color);label(s,x+12,y+8,w-24,23,16,color,true)
}
func sceneDraw(_ s:Int,_ t:Double) {
    switch s {
    case 1:
        chrome(t,"Keep it, or start over?","A four-bar idea with a phrase that enters late","Fictional songwriting example · no actual Suno test")
        if t<3.5 {
            let path=CommandLine.arguments[3]
            if let photo=NSImage(contentsOfFile:path) {photo.draw(in:NSRect(x:54,y:166,width:1172,height:355),from:NSRect(origin:.zero,size:photo.size),operation:.sourceOver,fraction:0.67)}
            rect(54,166,1172,355,bg,0,0.33)
            label("ONE PROMISING PHRASE",92,345,900,60,39,cream,true)
        } else {
            timelineBase();melody(t-3)
            let p=ramp(t,4,8)
            if p>0 {clip(205+120*p,262,610,coral,"NEW PHRASE · LATE",true)}
            if t>18 {sourceTag("KEEP + EDIT?",737,106,210,mint);sourceTag("REGENERATE?",970,106,230,coral)}
            cursor(790+200*ramp(t,18,25),358)
        }
    case 2:
        chrome(t,"Can the phrase meet beat one?","New beat detection is a claim about new clips","Suno release note · October 8, 2026")
        timelineBase();melody(9)
        let oldx:CGFloat=330
        clip(oldx,267,590,coral,"EXISTING TAKE · STILL LATE")
        if t>5 {line(205,211,205,507,amber,5);label("BEAT ONE",210,222,150,26,18,amber,true)}
        let gp=ramp(t,12,16)
        if gp>0 {rect(205,278-80*gp,590*gp,67,mint,8,0.2,mint);if gp>0.96 {wav(216,208,568,45,mint);label("POSSIBLE NEW TAKE",216,184,300,26,16,mint,true)}}
        if t>22 {sourceTag("LISTEN AND COMPARE",865,104,325,amber)}
    case 3:
        chrome(t,"What if it ends too early?","Drag the selected clip to lengthen the phrase","Suno release note · October 8, 2026")
        timelineBase();melody(9)
        let extend=ramp(t,7,18)
        let width:CGFloat=460+280*extend
        clip(230,269,width,mint,"SELECTED CLIP",true)
        line(230+width,258,230+width,349,amber,4)
        cursor(232+width,372)
        if t>9 {sourceTag("SHIFT + CLICK + DRAG",840,118,350,amber)}
        if t>21 {sourceTag("DOES IT SOUND NATURAL?",804,96,388,coral)}
    case 4:
        chrome(t,"An abrupt ending","Two different fade shapes; neither is a quality result","Suno release note · October 8, 2026")
        timelineBase();melody(9)
        clip(228,270,750,mint,"ENDING OF SELECTED CLIP",true)
        let g=ramp(t,6,18)
        if g>0 {
            gainGraph(80,83,0,g)
            gainGraph(475,83,1,max(0,(g-0.25)/0.75))
            label("CURVE A",98,235,175,25,16,mint,true)
            label("CURVE B",493,235,175,25,16,amber,true)
        }
        if t>21 {sourceTag("CHOOSE BY LISTENING",867,108,320,coral)}
    case 5:
        chrome(t,"More space in the workspace","Pop-out views help layout; they do not repair a clip","Suno release note · October 8, 2026")
        let m=ramp(t,1,6)
        for i in 0..<3 {
            let start:CGFloat=315
            let x=start+CGFloat(i)*35+CGFloat(i-1)*220*m
            let y:CGFloat=213+CGFloat((i%2)-1)*37*m
            rect(x,y,440,238,panel2,13,1,grid)
            rect(x,y+206,440,32,grid,10)
            label(["SYNTH","MUSICAL TYPING","PLUG-INS"][i],x+20,y+208,375,25,17,cream,true)
            for j in 0..<5 {rect(x+30+CGFloat(j)*61,y+80+CGFloat(j%2)*24,37,57,mint,4,0.25)}
        }
        cursor(639+350*m,450)
    case 6:
        if t < 23 {
            chrome(t,"First workflow: edit the stems","A creator described cleaning and shaping five separate tracks","On a Creative Journey · October 9 · reported workflow")
            rect(60,168,1150,337,panel,14,1,grid)
            let colors=[mint,amber,coral,0x9FA8EF,0xE0A7D0]
            for i in 0..<5 {
                let y:CGFloat=425-CGFloat(i)*57
                let appear=ramp(t,Double(i)*1.5+2,Double(i)*1.5+4)
                if appear>0 {
                    label("STEM \(i+1)",211,y+12,80,24,15,colors[i],true)
                    rect(290,y,800*appear,45,colors[i],7,0.19,colors[i])
                    wav(301,y+4,max(24,778*appear),36,colors[i],CGFloat(i)*0.7)
                }
                fader(86+CGFloat(i)*23,371,CGFloat((sin(t*1.3+Double(i))*0.34+0.5)),colors[i])
            }
            if t>12 {sourceTag("NOISE · TONE · DYNAMICS",430,101,420,mint)}
        } else if t < 35 {
            chrome(t,"Second workflow: sample the material","A different creator described bringing generated material into his production","Todd Edwards via MusicRadar · September 29 · reported practice")
            rect(70,215,480,280,panel,14,1,grid)
            rect(730,215,480,280,panel,14,1,grid)
            label("GENERATED MATERIAL",94,446,430,30,19,mint,true)
            label("SONG ARRANGEMENT",754,446,430,30,19,amber,true)
            wav(105,335,400,74,mint,0.3)
            for i in 0..<2 {wav(755,360-CGFloat(i)*55,400,38,[amber,pale][i],CGFloat(i))}
            let m=ramp(t,24,30)
            let tileX:CGFloat=325+540*m
            rect(tileX,239,155,47,mint,8,0.35,mint)
            wav(tileX+10,248,132,28,mint)
            line(575,353,694,353,amber,4)
            line(681,365,694,353,amber,4);line(681,341,694,353,amber,4)
        } else {
            chrome(t,"What do these examples show?","Two ways to shape a first take after generation","On a Creative Journey · Todd Edwards · separate creator accounts")
            rect(68,226,538,244,panel,14,1,mint)
            rect(674,226,538,244,panel,14,1,amber)
            label("FIVE STEMS",97,404,476,30,22,mint,true)
            label("Clean and adjust the tracks",97,333,476,43,25,cream)
            label("SAMPLING",703,404,476,30,22,amber,true)
            label("Place material in a larger song",703,333,476,43,25,cream)
            sourceTag("NEITHER ACCOUNT TESTED THE OCTOBER CONTROLS",260,119,760,coral)
        }
    default:
        chrome(t,"Keep the original. Change one thing.","A fair A/B listen needs a reference","Suno release note · creator accounts · our proposed listening process")
        rect(54,203,1172,318,panel,14,1,grid)
        rect(54,480,1172,41,panel2,12)
        for i in 0...4 {
            let x:CGFloat=232+CGFloat(i)*235
            line(x,215,x,513,grid,i==0 ? 2 : 1)
            if i<4 {label("BAR \(i+1)",x+8,487,130,26,15,pale,true)}
        }
        label("MELODY",71,432,145,28,17,mint,true)
        label("ORIGINAL",71,338,145,28,17,amber,true)
        label("ONE EDIT",71,252,145,28,17,mint,true)
        for (i,v) in [0,2,1,3,2,1,2,0,3,2,1,0].enumerated() {
            rect(247+CGFloat(i)*76,430+CGFloat(v)*9,47,7,mint,4)
        }
        rect(233,325,710,56,amber,8,0.19,amber)
        wav(246,333,682,40,amber)
        let m=ramp(t,6,14)
        rect(233+55*m,236,710,56,mint,8,0.19,mint)
        wav(246+55*m,244,682,40,mint)
        if t>=15 && t<31 {
            sourceTag("1  ENTRANCE",71,113,344,mint)
            sourceTag("2  STRETCH",468,113,344,amber)
            sourceTag("3  FADE",865,113,344,coral)
        } else if t>=31 && t<42 {
            sourceTag("THE CONTROLS EXIST",96,113,493,mint)
            sourceTag("BETTER SONG? UNPROVEN",692,113,493,coral)
        } else if t>=42 {
            sourceTag("NEXT: LISTEN A / B",437,113,406,amber)
        }
    }
}

let bytesPerRow=W*4
let rep=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:W,pixelsHigh:H,bitsPerSample:8,
                         samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,
                         bytesPerRow:bytesPerRow,bitsPerPixel:32)!
let out=FileHandle.standardOutput
let frames = CommandLine.arguments.count > 4 ? Int(CommandLine.arguments[4])! : Int(duration*Double(fps))
for frame in 0..<frames {
    let context=NSGraphicsContext(bitmapImageRep:rep)!
    NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=context
    sceneDraw(scene,Double(frame)/Double(fps))
    context.flushGraphics();NSGraphicsContext.restoreGraphicsState()
    out.write(Data(bytes:rep.bitmapData!,count:bytesPerRow*H))
}
