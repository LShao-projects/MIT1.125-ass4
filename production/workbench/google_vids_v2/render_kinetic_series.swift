import AppKit
import Foundation

// Original silent animated footage for Episodes 2 and 3. These are illustrations,
// not a real Suno, Deezer, or distributor interface and not measured audio files.
let episode = Int(CommandLine.arguments[1])!
let scene = Int(CommandLine.arguments[2])!
let fps = Int(CommandLine.arguments[3])!
let durations: [Int: [Double]] = [2: [35,39,35,35,40,44], 3: [34,44,44,43,38,41], 4: [42,44,44,44,44,48], 5: [34,44,44,43,38,41]]
let duration = durations[episode]![scene-1]
let W=1280, H=720
let bg=0x07151D, panel=0x102630, panel2=0x193542, cream=0xF5F1E8
let pale=0xB7CAD0, mint=0x84DEC5, amber=0xF4B766, coral=0xEB867A, grid=0x385461
func c(_ h:Int,_ a:CGFloat=1)->NSColor { NSColor(calibratedRed:CGFloat((h>>16)&255)/255,green:CGFloat((h>>8)&255)/255,blue:CGFloat(h&255)/255,alpha:a) }
func rect(_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat,_ color:Int,_ r:CGFloat=0,_ alpha:CGFloat=1,_ stroke:Int?=nil) {
    let p=NSBezierPath(roundedRect:NSRect(x:x,y:y,width:w,height:h),xRadius:r,yRadius:r)
    c(color,alpha).setFill();p.fill();if let s=stroke {c(s).setStroke();p.lineWidth=1.5;p.stroke()}
}
func line(_ x:CGFloat,_ y:CGFloat,_ xx:CGFloat,_ yy:CGFloat,_ color:Int,_ width:CGFloat=2,_ alpha:CGFloat=1) {
    let p=NSBezierPath();p.move(to:NSPoint(x:x,y:y));p.line(to:NSPoint(x:xx,y:yy));p.lineWidth=width;p.lineCapStyle = .round;c(color,alpha).setStroke();p.stroke()
}
func text(_ s:String,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat,_ size:CGFloat=20,_ color:Int=cream,_ bold:Bool=false) {
    let para=NSMutableParagraphStyle();para.lineBreakMode = .byTruncatingTail
    let a:[NSAttributedString.Key:Any] = [.font:NSFont.systemFont(ofSize:size,weight:bold ? .semibold : .regular),.foregroundColor:c(color),.paragraphStyle:para]
    (s as NSString).draw(in:NSRect(x:x,y:y,width:w,height:h),withAttributes:a)
}
func ease(_ v:Double)->CGFloat {let z=max(0,min(1,v));return CGFloat(z*z*(3-2*z))}
func ramp(_ t:Double,_ a:Double,_ b:Double)->CGFloat {ease((t-a)/(b-a))}
func wave(_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat,_ color:Int,_ seed:CGFloat=0) {
    for i in 0..<68 {let u=CGFloat(i)/68;let amp:CGFloat=0.18+0.72*abs(sin(u*18+seed)*cos(u*37+seed));rect(x+u*w,y+(h-h*amp)/2,max(2,w/68-2),h*amp,color,2)}
}
func music(_ x:CGFloat,_ y:CGFloat,_ color:Int,_ shift:CGFloat=0) {
    let notes:[CGFloat]=[0,2,1,3,2,0,2,3,1,2,1,0]
    for (i,n) in notes.enumerated() {rect(x+CGFloat(i)*65+shift,y+n*13,42,9,color,4)}
}
func compactMusic(_ x:CGFloat,_ y:CGFloat,_ color:Int,_ step:CGFloat=37) {
    let notes:[CGFloat]=[0,2,1,3,2,0,2,3,1,2,1,0]
    for (i,n) in notes.enumerated() {rect(x+CGFloat(i)*step,y+n*10,step-10,8,color,4)}
}
func tag(_ s:String,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ color:Int) {
    rect(x,y,w,39,color,8,0.12,color);text(s,x+12,y+9,w-24,25,16,color,true)
}
func header(_ t:Double,_ title:String,_ sub:String,_ source:String) {
    rect(0,0,1280,720,bg);rect(0,654,1280,66,panel)
    for i in 0..<3 {rect(22+CGFloat(i)*22,680,10,10,[coral,amber,mint][i],5)}
    text("STUDIO / EDIT SESSION",105,674,450,28,17,cream,true)
    text("ILLUSTRATION · NOT SUNO UI",989,674,270,25,14,pale,true)
    text(title,54,579,1170,63,38,cream,true);text(sub,56,544,1150,32,20,pale)
    rect(0,0,1280,53,panel);text(source,46,14,1170,27,16,pale)
    rect(0,0,CGFloat(t/duration)*1280,4,mint)
}
func playhead(_ t:Double,_ x:CGFloat,_ y:CGFloat,_ h:CGFloat,_ w:CGFloat) {
    let px=x+CGFloat((t*0.17).truncatingRemainder(dividingBy:1))*w
    line(px,y,px,y+h,amber,3);rect(px-6,y+h-4,12,12,amber,3)
}
func box(_ title:String,_ detail:String,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ color:Int) {
    rect(x,y,w,136,panel,13,1,color);text(title,x+20,y+92,w-40,32,22,color,true);text(detail,x+20,y+43,w-40,32,19,cream)
}
func arrow(_ x:CGFloat,_ y:CGFloat,_ xx:CGFloat,_ color:Int) {
    line(x,y,xx,y,color,4);line(xx-13,y+11,xx,y,color,4);line(xx-13,y-11,xx,y,color,4)
}
func scene2(_ t:Double) {
    switch scene {
    case 1:
        header(t,"A or B: what is better?","One fictional song · two imaginary exports","Illustration · no Suno audio or measured result · evidence as of Oct 13, 2026")
        box("EXPORT A","Louder on the meter",73,306,531,amber)
        box("EXPORT B","Follows the melody",677,306,531,mint)
        wave(100,315,471,31,amber);music(700,315,mint)
        if t>5 {rect(72,223,1135,54,panel2,9);rect(74,225,1060*ramp(t,5,12),50,amber,7,0.5);text("LEVEL",92,238,180,28,19,cream,true)}
        if t>15 {line(638,204,638,465,grid,2);tag("FILE QUALITY",179,146,342,amber);tag("MUSICAL INTENT",757,146,342,mint)}
        playhead(t,73,303,143,1135)
    case 2:
        header(t,"The meter measures a file","Loudness and True Peak answer narrow questions","WaveDisco · three songs, four model versions · reported measurements")
        rect(69,166,542,344,panel,14,1,grid);rect(668,166,542,344,panel,14,1,grid)
        text("LOUDNESS",100,453,450,37,22,mint,true);text("TRUE PEAK",700,453,450,37,22,amber,true)
        wave(102,303,475,89,mint,CGFloat(t*0.7));wave(701,303,475,89,amber,CGFloat(t*0.5))
        let m=ramp(t,7,15);line(120,260,120+440*m,260,mint,5);line(718,260,718+440*m,260,amber,5)
        if t>16 {tag("THREE SONGS · FOUR VERSIONS",417,185,445,pale)}
        if t>28 {tag("NO CONSISTENT WINNER",444,102,391,coral)}
    case 3:
        header(t,"Check the file you will share","A two-song format result is a reason to inspect","WaveDisco · WAV / MP3 comparison · only two paired songs")
        rect(77,233,278,247,panel,14,1,grid);rect(485,233,278,247,panel,14,1,grid);rect(893,233,278,247,panel,14,1,grid)
        text("WAV",126,382,180,56,35,mint,true);text("MP3",543,382,180,56,35,amber,true);text("UPLOAD",920,382,220,56,35,cream,true)
        wave(112,280,206,55,mint);wave(520,280,206,55,amber,1)
        arrow(373,352,460,amber);arrow(780,352,867,amber)
        if t>10 {line(830,250,830,472,coral,4);tag("WHICH EXPORT?",467,155,346,coral)}
        if t>23 {tag("INSPECT THE EXACT FILE",449,99,383,mint)}
    case 4:
        header(t,"What caused that difference?","The chart is about files; model effect is unresolved","ytyng · compared files with different prompts and codecs")
        rect(72,189,1137,307,panel,15,1,grid)
        for i in 0...4 {line(120,233+CGFloat(i)*53,1161,233+CGFloat(i)*53,grid,1)}
        let path=NSBezierPath();path.move(to:NSPoint(x:127,y:438));for i in 0...90 {let u=CGFloat(i)/90;let x:CGFloat=127+1020*u;if x>127+1020*ramp(t,2,13) {break};let y:CGFloat=260+150*exp(-u*2.5)+11*sin(u*30);path.line(to:NSPoint(x:x,y:y))};path.lineWidth=4;c(mint).setStroke();path.stroke()
        if t>14 {tag("PROMPT",110,127,258,amber);tag("SONG",390,127,258,coral);tag("CODEC",670,127,258,mint);tag("MODEL?",950,127,235,pale)}
        playhead(t,122,210,260,1040)
    case 5:
        header(t,"Did it keep your idea?","Creators listened for different parts of the song","On a Creative Journey · Andrea Olson · individual creator accounts")
        rect(68,300,1144,201,panel,14,1,grid);text("ORIGINAL MELODY",91,447,350,30,20,mint,true);music(108,355,mint)
        if t>6 {box("GENERATE + CLEAN","One creator revised vocals",70,113,530,amber)}
        if t>16 {box("VOICE MEMO","Olson heard much of her melody",680,113,530,coral)}
        if t>30 {tag("ACCOUNTS, NOT AVERAGES",440,90,400,pale)}
        playhead(t,80,301,195,1110)
    default:
        header(t,"Two checks. Your decision.","File inspection and musical intention are different gates","Editorial test · informed by WaveDisco, ytyng and creator accounts")
        box("1 · EXACT EXPORT","Format · level · peaks",68,347,542,amber)
        box("2 · YOUR IDEA","Melody · vocal · arrangement",670,347,542,mint)
        if t>8 {arrow(350,311,591,amber);arrow(930,311,1130,mint)}
        rect(384,177,512,84,panel2,14,1,grid);text("RELEASE FOLDER",435,202,410,45,29,cream,true)
        if t>24 {tag("PUBLISH? NEXT EPISODE",416,103,448,coral)}
        playhead(t,72,339,151,1130)
    }
}
// Episode 2 clarity revision. Keep the songwriter's decision visible while moving
// from musical intention to the exact export and then to the evidence limits.
func scene2Clarity(_ t:Double) {
    switch scene {
    case 1:
        header(t,"Which version serves your song?","Your melody · two imaginary candidates","Illustration · no Suno audio or measured result · evidence as of Oct 13, 2026")
        rect(68,426,1144,106,panel,13,1,grid)
        text("YOUR ORIGINAL MELODY",93,483,430,29,19,mint,true);compactMusic(106,444,mint,59)
        box("VERSION A","Louder on a fictional meter",71,231,529,amber)
        box("VERSION B","Closer to the drawn melody",680,231,529,mint)
        wave(102,251,467,24,amber);compactMusic(706,250,mint,39)
    case 2:
        header(t,"Start with your music","Melody · vocal direction · arrangement","On a Creative Journey · individual creator demonstration")
        rect(72,440,1136,89,panel,14,1,grid)
        text("ORIGINAL SONG IDEA",96,489,340,28,19,mint,true);compactMusic(105,454,mint,59)
        let titles=["1 · LYRIC DIRECTIONS","2 · MORE GENERATIONS","3 · STUDIO CLEANUP"]
        let colors=[mint,amber,coral]
        for i in 0..<3 {
            let x=75+CGFloat(i)*404
            let a=ramp(t,3+Double(i)*8,8+Double(i)*8)
            rect(x,329,322,79,panel,12,0.55+0.45*a,colors[i])
            text(titles[i],x+15,354,296,27,17,colors[i],true)
            if i<2 && t>8+Double(i)*8 {arrow(x+329,368,x+391,pale)}
        }
        rect(75,192,512,104,panel,12,1,grid)
        rect(693,192,512,104,panel,12,1,mint)
        text("EARLIER TAKE",94,252,460,29,18,pale,true)
        text("LATER VOCAL PREFERRED",712,252,470,29,18,mint,true)
        wave(96,210,459,28,pale);wave(715,210,459,28,mint,1)
    case 3:
        header(t,"One memo, two judgments","Following the idea is not the same as sounding finished","Andrea Olson · songwriter and producer / Produce Like a Boss")
        rect(87,430,1106,91,panel,13,1,grid)
        text("UPLOADED VOICE MEMO",113,480,420,29,20,mint,true)
        wave(570,449,563,43,mint)
        if t>6 {arrow(583,404,697,amber)}
        rect(87,230,513,148,panel,13,1,mint)
        rect(680,230,513,148,panel,13,1,amber)
        text("MELODY: MUCH RETAINED",107,331,480,31,20,mint,true)
        text("Her reported positive judgment",108,275,476,29,18,cream)
        text("SOUND: STILL AI-LIKE",701,331,468,31,20,amber,true)
        text("Her reported limitation",701,275,468,29,18,cream)
    case 4:
        header(t,"Now check the chosen file","Level · peaks · format are export properties","WaveDisco · three songs, four versions · two paired-format songs")
        rect(78,416,1124,105,panel,15,1,grid)
        text("YOUR SELECTED EXPORT",107,475,510,31,21,mint,true)
        wave(570,442,560,47,mint)
        let checks=["LOUDNESS","TRUE PEAK","FORMAT"]
        let checkColors=[mint,amber,coral]
        for i in 0..<3 {
            let x=79+CGFloat(i)*401
            let a=ramp(t,6+Double(i)*6,11+Double(i)*6)
            rect(x,236,319,144,panel,13,0.45+0.55*a,checkColors[i])
            text(checks[i],x+20,330,279,31,20,checkColors[i],true)
            text(["Check the file's level","Check brief signal peaks","Check WAV or MP3"][i],x+20,270,279,29,17,cream)
        }
        if t>28 {text("The reported v5.5–v6 measures did not give one consistent winner.",258,171,844,28,18,pale)}
    case 5:
        header(t,"A chart cannot choose for you","Observed difference does not isolate its cause","ytyng · reported exports with different songs, prompts and codecs")
        rect(74,245,533,268,panel,14,1,grid)
        rect(654,245,552,268,panel,14,1,amber)
        text("REPORTED SPECTRUM",98,463,486,30,20,mint,true)
        text("OTHER THINGS CHANGED",678,463,505,30,20,amber,true)
        for i in 0...3 {line(109,284+CGFloat(i)*42,576,284+CGFloat(i)*42,grid,1)}
        let path=NSBezierPath();path.move(to:NSPoint(x:111,y:419))
        for i in 0...90 {
            let u=CGFloat(i)/90
            let x:CGFloat=111+453*u
            if x>111+453*ramp(t,2,12) {break}
            let y:CGFloat=297+114*exp(-u*2.4)+7*sin(u*31)
            path.line(to:NSPoint(x:x,y:y))
        }
        path.lineWidth=4;c(mint).setStroke();path.stroke()
        let variables=["SONG","PROMPT","ENCODING"]
        for i in 0..<3 {
            let y=390-CGFloat(i)*55
            let a=ramp(t,13+Double(i)*5,17+Double(i)*5)
            rect(679,y,501,42,amber,8,0.05+0.14*a,amber)
            text(variables[i],698,y+9,461,25,17,cream,true)
        }
        if t>31 {text("The chart cannot isolate the model as the cause.",357,178,690,29,18,pale)}
    default:
        header(t,"Keep the idea. Check the file.","Two successive checks for the version you may share","Editorial synthesis · WaveDisco, ytyng and two creator accounts")
        rect(66,326,545,173,panel,15,1,mint)
        rect(670,326,545,173,panel,15,1,amber)
        text("1 · YOUR MUSIC",92,435,485,37,25,mint,true)
        text("Melody · vocal · arrangement",93,379,475,33,20,cream)
        if t>9 {
            arrow(612,414,659,mint)
            text("2 · YOUR EXPORT",699,435,485,37,25,amber,true)
            text("The exact file you will share",699,379,475,33,20,cream)
        }
        if t>22 {tag("SAVE MEMO + VERSIONS + SETTINGS",394,233,491,pale)}
    }
}
func scene3(_ t:Double) {
    switch scene {
    case 1:
        header(t,"Pause before Publish","The same fictional songwriter reaches the upload step","Illustration · no real account or upload · evidence as of Oct 13, 2026")
        rect(75,197,1130,319,panel,16,1,grid);text("Untitled song  ·  final-export.wav",104,453,1000,40,25,cream,true)
        wave(105,344,775,62,mint);rect(921,313,229,77,coral,11,0.25,coral);text("PUBLISH",955,336,175,36,25,cream,true)
        let p=ramp(t,3,11);line(813,257,971*p+813*(1-p),329,amber,4)
        if t>13 {tag("WHO MADE WHAT?",94,113,318,mint);tag("WHICH RULES?",478,113,318,amber);tag("WHICH CATEGORY?",863,113,318,coral)}
        playhead(t,105,305,110,775)
    case 2:
        header(t,"Trace your process","Keep the inputs, outputs and your edits with dates","Zemi · Josh / JG Beats Lab · Andrea Olson · different creator workflows")
        rect(85,185,1110,310,panel,16,1,grid)
        let names=["VOICE MEMO","LYRICS","PROMPTS","GENERATIONS","LATER EDITS"]
        for i in 0..<5 {let x=108+CGFloat(i)*214;let a=ramp(t,Double(i)*3+2,Double(i)*3+7);rect(x,270+20*a,190,144,[mint,amber,pale,coral,mint][i],10,0.17,[mint,amber,pale,coral,mint][i]);text(names[i],x+13,365+20*a,170,52,17,cream,true);text("dated",x+14,301+20*a,125,27,16,pale)}
        if t>25 {tag("A RECORD EXPLAINS THE STEPS",385,119,509,mint)}
        playhead(t,104,245,225,1050)
    case 3:
        header(t,"Which rules apply today?","A process folder does not establish your rights","Italian Competition Authority · investigation, not a ruling")
        rect(67,208,412,288,panel,13,1,mint);rect(533,208,679,288,panel,13,1,amber)
        text("YOUR RECORD",93,442,350,31,22,mint,true);text("CURRENT TERMS",559,442,600,31,22,amber,true)
        for i in 0..<4 {rect(97,400-CGFloat(i)*43,290,26,mint,6,0.2);rect(561,400-CGFloat(i)*43,580,26,grid,6)}
        if t>9 {tag("ACCOUNT + DATE",553,145,305,amber);tag("RELEASE SERVICE",878,145,305,amber)}
        if t>24 {tag("VERIFY PRIMARY TERMS",439,101,403,coral)}
        playhead(t,79,215,266,1100)
    case 4:
        header(t,"Three different questions","An industry dispute does not decide this upload","Suno statement · Sony / Universal allegations · LA Times reporting")
        let colors=[mint,coral,amber];let titles=["THIS UPLOAD","TRAINING DISPUTE","INDUSTRY DEALS"]
        let subs=["Account + destination terms","Claims and responses","Payouts, consent, control"]
        for i in 0..<3 {let y=400-CGFloat(i)*112;let x=80+CGFloat(90*ramp(t,Double(i)*3,Double(i)*3+5));rect(x,y,1120,91,panel,12,1,colors[i]);text(titles[i],x+22,y+46,350,32,21,colors[i],true);text(subs[i],x+370,y+45,700,30,19,cream);if i==0 && t>22 {tag("CHECK HERE",992,y+10,185,mint)}}
        if t>29 {tag("NOT A RULING ABOUT YOUR SONG",416,90,448,pale)}
    case 5:
        header(t,"How will this track be classified?","A planned listener filter leaves mixed-input tracks unclear","Deezer · reported plan for fully AI-generated music filter")
        rect(78,221,1124,279,panel,14,1,grid)
        text("LISTENER SEARCH",101,445,550,33,22,cream,true)
        rect(104,371,706,53,panel2,9,1,grid);text("Search for a song",121,385,600,29,19,pale)
        let v=ramp(t,7,13);rect(865,337,287,82,amber,12,0.06+0.09*v,amber);text("AI FILTER · PLANNED",883,368,256,29,17,amber,true)
        if t>19 {tag("PARTLY ASSISTED? UNKNOWN",433,245,416,coral)}
        if t>28 {tag("CHECK THE ACTUAL POLICY",439,111,404,mint)}
        playhead(t,95,231,205,1080)
    default:
        header(t,"Know the answer before the click","The cursor stays paused until the creator verifies the blanks","Editorial guidance · creator records, current terms, platform policy")
        let items=["YOUR CONTRIBUTIONS","CURRENT RULES","PLATFORM CLASSIFICATION"]
        let colors=[mint,amber,coral]
        for i in 0..<3 {let y=397-CGFloat(i)*97;rect(105,y,1066,79,panel,10,1,colors[i]);rect(127,y+19,38,38,colors[i],8,0.18,colors[i]);if i<2 && t>Double(i)*7+6 {text("✓",135,y+23,30,33,23,colors[i],true)};text(items[i],186,y+22,900,37,23,cream,true)}
        if t>28 {tag("VERIFY THE UNKNOWN BEFORE PUBLISH",361,85,558,coral)}
        playhead(t,108,183,292,1060)
    }
}
// Episode 3 visual revision: large, stationary information and no traveling playhead.
// Every scene is fully drawn from its first frame. The illustrations are generic,
// and none represents the actual Suno, Deezer, or distributor interface.
func cleanHeader(_ title:String,_ sub:String,_ source:String) {
    rect(0,0,1280,720,bg)
    rect(0,645,1280,75,panel)
    for i in 0..<3 {rect(26+CGFloat(i)*23,678,11,11,[coral,amber,mint][i],6)}
    text("CREATOR / RELEASE DESK",112,673,570,30,19,cream,true)
    text("ILLUSTRATION",1010,674,238,28,18,pale,true)
    text(title,68,574,1145,62,47,cream,true)
    text(sub,72,530,1130,37,27,pale)
    rect(0,0,1280,51,panel)
    text(source,43,14,1195,27,17,pale)
}
func cleanCard(_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat,_ color:Int) {
    rect(x,y,w,h,panel,19,1,color)
    rect(x,y+h-9,w,9,color,5)
}
func checkMark(_ x:CGFloat,_ y:CGFloat,_ color:Int) {
    rect(x,y,42,42,color,10,0.16,color)
    line(x+10,y+21,x+18,y+13,color,4)
    line(x+18,y+13,x+33,y+31,color,4)
}
func scene3Revision(_ t:Double) {
    switch scene {
    case 1:
        cleanHeader("Before you press Publish", "One song, three questions to verify", "Fictional songwriter · no real account or upload")
        cleanCard(70,226,734,285,mint)
        text("YOUR TRACK",104,453,635,40,32,mint,true)
        text("final-export.wav",104,385,640,50,37,cream,true)
        wave(105,288,626,57,mint)
        rect(876,321,319,106,coral,17,0.22,coral)
        text("PUBLISH",916,350,240,54,40,cream,true)
        text("PAUSE HERE",904,257,280,43,30,amber,true)
        let questions=["Who made what?", "Which rules?", "How classified?"]
        let colors=[mint,amber,coral]
        for i in 0..<3 {
            let x=70+CGFloat(i)*383
            rect(x,151,351,61,panel2,12,1,colors[i])
            text(questions[i],x+17,166,318,39,27,cream,true)
        }
    case 2:
        cleanHeader("What did you contribute?", "Keep dated inputs, versions, and edits", "Zemi · Josh / JG Beats Lab · Andrea Olson · individual workflows")
        let xs:[CGFloat]=[70,470,870]
        let colors=[mint,amber,coral]
        let titles=["YOUR INPUTS", "SUNO VERSIONS", "YOUR EDITS"]
        let details=["Memo + lyrics", "Save each take", "Mix + changes"]
        for i in 0..<3 {
            let x=xs[i]
            cleanCard(x,219,339,286,colors[i])
            text(titles[i],x+23,437,293,43,30,colors[i],true)
            text(details[i],x+23,261,294,37,27,cream,true)
        }
        compactMusic(100,345,mint,19)
        rect(507,335,255,68,panel2,10,1,amber)
        text("TAKE 01",532,353,210,35,25,amber,true)
        rect(507,316,255,12,amber,6,0.55)
        rect(913,341,244,10,coral,5,0.8)
        rect(913,368,194,10,coral,5,0.8)
        rect(913,395,218,10,coral,5,0.8)
        text("A dated trail explains the process.",294,157,741,46,34,cream,true)
    case 3:
        cleanHeader("A folder is not permission", "Check the rules that apply today", "Italian Competition Authority · investigation, not a ruling")
        cleanCard(70,213,510,300,mint)
        cleanCard(636,213,574,300,amber)
        text("YOUR RECORD",101,452,445,44,34,mint,true)
        checkMark(103,372,mint);text("Inputs",165,380,355,35,28,cream,true)
        checkMark(103,304,mint);text("Outputs",165,312,355,35,28,cream,true)
        checkMark(103,236,mint);text("Later edits",165,244,355,35,28,cream,true)
        text("CURRENT RULES",667,452,510,44,34,amber,true)
        text("Suno account + plan",671,378,501,38,29,cream,true)
        text("Release service",671,313,501,38,29,cream,true)
        text("Date checked",671,248,501,38,29,cream,true)
        text("Your record explains steps. Read the actual terms.",141,151,1000,44,31,cream,true)
    case 4:
        cleanHeader("Separate the questions", "An industry headline cannot clear this upload", "Suno statement · label allegations · LA Times reporting")
        let xs:[CGFloat]=[70,472,874]
        let colors=[mint,coral,amber]
        let titles=["YOUR UPLOAD", "TRAINING CASE", "INDUSTRY DEALS"]
        let details=["Check today's terms", "Claims are disputed", "Payouts unclear"]
        for i in 0..<3 {
            let x=xs[i]
            cleanCard(x,220,336,290,colors[i])
            text(titles[i],x+19,440,298,43,28,colors[i],true)
            text(details[i],x+19,267,298,37,25,cream,true)
        }
        rect(115,350,244,56,panel2,10,1,mint)
        text("THIS SONG",142,361,200,36,25,mint,true)
        rect(521,350,236,56,panel2,10,1,coral)
        text("NOT A RULING",538,361,208,36,24,coral,true)
        rect(922,350,231,56,panel2,10,1,amber)
        text("ASK FOR DETAIL",933,361,210,36,22,amber,true)
        text("Keep these evidence paths separate.",328,154,719,46,33,cream,true)
    case 5:
        cleanHeader("Will listeners find it?", "The filter is a reported plan; mixed input is unclear", "Deezer · proposed search filter for fully AI-generated tracks")
        cleanCard(70,219,745,291,mint)
        text("LISTENER SEARCH",102,443,670,44,34,mint,true)
        rect(102,352,675,65,panel2,12,1,grid)
        text("Search music",129,366,595,40,29,pale)
        rect(104,258,670,67,panel2,12,1,grid)
        text("Your song might appear here",130,273,605,42,29,cream,true)
        cleanCard(859,219,352,291,amber)
        text("PLANNED FILTER",881,441,311,45,29,amber,true)
        text("Fully AI-made",883,363,300,43,29,cream,true)
        rect(897,290,95,48,grid,24)
        rect(903,295,38,38,pale,20)
        text("OFF",1013,297,151,42,27,pale,true)
        text("Human + AI? Classification unknown.",217,151,880,47,34,cream,true)
    default:
        cleanHeader("Verify before you publish", "Three checks, then make your release decision", "Editorial guidance · records, current terms, platform policy")
        let ys:[CGFloat]=[409,305,201]
        let colors=[mint,amber,coral]
        let titles=["YOUR CONTRIBUTIONS", "CURRENT RULES", "TRACK CLASSIFICATION"]
        for i in 0..<3 {
            let y=ys[i]
            rect(69,y,810,84,panel,12,1,colors[i])
            rect(89,y+22,40,40,colors[i],10,0.11,colors[i])
            text(titles[i],150,y+23,696,42,29,cream,true)
        }
        rect(929,300,287,116,coral,17,0.18,coral)
        text("PUBLISH?",964,339,218,47,36,cream,true)
        text("Unknown rule?",928,247,284,38,27,amber,true)
        text("Check first.",946,208,253,41,30,cream,true)
    }
}
let bytesPerRow=W*4
let rep=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:W,pixelsHigh:H,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:bytesPerRow,bitsPerPixel:32)!
let output=FileHandle.standardOutput
let frames: [Int] = CommandLine.arguments.count > 4 ? [Int(CommandLine.arguments[4])!] : Array(0..<Int(duration*Double(fps)))
for f in frames {
    let ctx=NSGraphicsContext(bitmapImageRep:rep)!
    NSGraphicsContext.saveGraphicsState();NSGraphicsContext.current=ctx
    if episode==2 {scene2(Double(f)/Double(fps))}
    else if episode==4 {scene2Clarity(Double(f)/Double(fps))}
    else if episode==5 {scene3Revision(Double(f)/Double(fps))}
    else {scene3(Double(f)/Double(fps))}
    ctx.flushGraphics();NSGraphicsContext.restoreGraphicsState()
    output.write(Data(bytes:rep.bitmapData!,count:bytesPerRow*H))
}
