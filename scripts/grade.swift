// Subject-aware NATURAL grade for talking-head reels + subject matte.
//
// usage: swift grade.swift <input.mov> <out_dir> [--look natural|pop|none] [--start s] [--duration s] [--width 1080]
//        swift grade.swift <input.mov> <out_dir> --frames 1,9.5 [--look natural|pop|none|all]   (stills only, for review)
//
// Writes <out_dir>/graded.mov  (H.264, Rec.709, video only)
//        <out_dir>/matte.mov   (H.264 grayscale subject mask, same timing)
// Then build the pop-out layer with ffmpeg, run inside the episode folder (same command as SKILL.md step 3):
//   ffmpeg -i graded.mov -i matte.mov -filter_complex "[1]format=gray,scale=1080:1920[m];[0][m]alphamerge,format=yuva420p" -c:v libvpx-vp9 -b:v 6M -auto-alt-ref 0 -row-mt 1 -deadline realtime -cpu-used 8 subject.webm
//
// v3 (2026-10-07): v1/v2 looked artificial (face over-lifted + desaturated, bright cut-out rim, cold room vs warm skin,
// fake heavy blur). Rule now: ONE global grade for the whole image (same white balance, same curve), and only a
// small, wide-feathered exposure difference between person and room. No per-layer colour temperature, no sharpening,
// no shadow lifting, light blur only.
import Foundation
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision

// ---- args
var pos: [String] = []; var opts: [String: String] = [:]
var it = CommandLine.arguments.dropFirst().makeIterator()
while let a = it.next() { if a.hasPrefix("--") { opts[String(a.dropFirst(2))] = it.next() } else { pos.append(a) } }
guard pos.count == 2 else { print("usage: swift grade.swift <input> <out_dir> [--start s] [--duration s] [--width px]"); exit(1) }
let inURL = URL(fileURLWithPath: pos[0]); let outDir = URL(fileURLWithPath: pos[1])
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
let outW = Int(opts["width"] ?? "1080")!

// ---- looks (one place, so every reel matches)
struct Look { let name: String; let subjEV: Float; let roomEV: Float; let roomSat: Float; let roomBlur: Double
  let lo: CGFloat; let hi: CGFloat; let vib: Float; let vignette: Float; let feather: Double }
let LOOKS: [String: Look] = [
  "natural": Look(name: "natural", subjEV: 0.08, roomEV: -0.30, roomSat: 0.95, roomBlur: 3, lo: 0.235, hi: 0.765, vib: 0.06, vignette: 0.22, feather: 12),
  "pop":     Look(name: "pop",     subjEV: 0.12, roomEV: -0.50, roomSat: 0.90, roomBlur: 5, lo: 0.225, hi: 0.775, vib: 0.08, vignette: 0.32, feather: 12),
  "none":    Look(name: "none",    subjEV: 0, roomEV: 0, roomSat: 1, roomBlur: 0, lo: 0.25, hi: 0.75, vib: 0, vignette: 0, feather: 2),
]
let lookName = opts["look"] ?? "pop"   // approved 2026-10-07

// ---- source
let asset = AVURLAsset(url: inURL)
let track = asset.tracks(withMediaType: .video).first!
let nat = track.naturalSize.applying(track.preferredTransform)
let srcW = abs(nat.width), srcH = abs(nat.height)
let outH = Int((Double(outW) * Double(srcH / srcW)).rounded() / 2) * 2
let fps = track.nominalFrameRate
let ctx = CIContext()                        // default linear working space (v1/v2 used a gamma working space: washed look)
let rec709 = CGColorSpace(name: CGColorSpace.itur_709)!
let req = VNGeneratePersonSegmentationRequest()
req.qualityLevel = .accurate
req.outputPixelFormat = kCVPixelFormatType_OneComponent8
var strength: Float = 0

func solid(_ c: CIColor, _ r: CGRect) -> CIImage { CIImage(color: c).cropped(to: r) }
func fit(_ img: CIImage) -> CIImage {
  let i = img.transformed(by: CGAffineTransform(translationX: -img.extent.minX, y: -img.extent.minY))
  let s = CGFloat(outW) / i.extent.width
  return i.transformed(by: CGAffineTransform(scaleX: s, y: s)).cropped(to: CGRect(x: 0, y: 0, width: outW, height: outH))
}

/// person mask (white = person), feathered
func personMask(_ inp: CIImage, seq: VNSequenceRequestHandler?, feather: Double) -> CIImage? {
  if let seq = seq { try? seq.perform([req], on: inp) } else { try? VNImageRequestHandler(ciImage: inp).perform([req]) }
  guard let pb = req.results?.first?.pixelBuffer else { return nil }
  let ext = inp.extent
  var m = CIImage(cvPixelBuffer: pb)
  m = m.transformed(by: CGAffineTransform(scaleX: ext.width / m.extent.width, y: ext.height / m.extent.height))
  m = m.clampedToExtent().applyingGaussianBlur(sigma: feather * Double(outW) / 1080).cropped(to: ext)
  let b = CIFilter.blendWithMask(); b.inputImage = solid(.white, ext); b.backgroundImage = solid(.black, ext); b.maskImage = m
  return b.outputImage!.cropped(to: ext)
}

func grade(_ inp: CIImage, _ L: Look, seq: VNSequenceRequestHandler?, fade: Bool) -> (CIImage, CIImage) {
  let ext = inp.extent
  // matte for the pop-out layer: tight edge
  guard let tight = personMask(inp, seq: seq, feather: 2) else { return (inp, solid(.black, ext)) }
  if L.name == "none" { return (inp, tight) }
  // wide feather for the grade blend, so the exposure step never draws an outline
  let wide = tight.clampedToExtent().applyingGaussianBlur(sigma: L.feather * Double(outW) / 1080).cropped(to: ext)

  if fade {   // person coverage -> fade the effect out on screen recordings / titles
    let avg = CIFilter.areaAverage(); avg.inputImage = tight; avg.extent = ext
    var px = [UInt8](repeating: 0, count: 4)
    ctx.render(avg.outputImage!, toBitmap: &px, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
    strength += (min(max((Float(px[0]) / 255 - 0.06) / 0.10, 0), 1) - strength) * 0.35
  } else { strength = 1 }

  // 1. global grade: same curve + vibrance for every pixel
  let tc = CIFilter.toneCurve(); tc.inputImage = inp
  tc.point0 = CGPoint(x: 0, y: 0); tc.point1 = CGPoint(x: 0.25, y: L.lo); tc.point2 = CGPoint(x: 0.5, y: 0.5)
  tc.point3 = CGPoint(x: 0.75, y: L.hi); tc.point4 = CGPoint(x: 1, y: 1)
  let vb = CIFilter.vibrance(); vb.inputImage = tc.outputImage; vb.amount = L.vib
  let base = vb.outputImage!.cropped(to: ext)
  // 2. person: tiny lift
  let se = CIFilter.exposureAdjust(); se.inputImage = base; se.ev = L.subjEV
  // 3. room: a bit darker, almost full colour, light blur
  let re = CIFilter.exposureAdjust(); re.inputImage = base; re.ev = L.roomEV
  let rc = CIFilter.colorControls(); rc.inputImage = re.outputImage; rc.saturation = L.roomSat
  var room = rc.outputImage!.cropped(to: ext)
  if L.roomBlur > 0 { room = room.clampedToExtent().applyingGaussianBlur(sigma: L.roomBlur * Double(outW) / 1080).cropped(to: ext) }
  let comp = CIFilter.blendWithMask(); comp.inputImage = se.outputImage!.cropped(to: ext); comp.backgroundImage = room; comp.maskImage = wide
  // 4. soft vignette over everything
  let vg = CIFilter.vignette(); vg.inputImage = comp.outputImage; vg.intensity = L.vignette; vg.radius = 1.8
  let graded = vg.outputImage!.cropped(to: ext)
  let mix = CIFilter.dissolveTransition(); mix.inputImage = inp; mix.targetImage = graded; mix.time = strength
  return (mix.outputImage!.cropped(to: ext), tight)
}

// ---- stills mode: --frames 1,9.5 -> still_<look>_<t>.png (original included as still_orig_<t>.png)
if let fr = opts["frames"] {
  let gen = AVAssetImageGenerator(asset: asset)
  gen.appliesPreferredTrackTransform = true
  gen.requestedTimeToleranceBefore = .zero; gen.requestedTimeToleranceAfter = .zero
  let looks = lookName == "all" ? ["natural", "pop"] : [lookName]
  for ts in fr.split(separator: ",") {
    let t = Double(ts)!
    let cg = try! gen.copyCGImage(at: CMTime(seconds: t, preferredTimescale: 600), actualTime: nil)
    let src = fit(CIImage(cgImage: cg))
    try! ctx.writePNGRepresentation(of: src, to: outDir.appendingPathComponent("still_orig_\(ts).png"), format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
    for ln in looks {
      let (g, _) = grade(src, LOOKS[ln]!, seq: nil, fade: false)
      try! ctx.writePNGRepresentation(of: g, to: outDir.appendingPathComponent("still_\(ln)_\(ts).png"), format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
    }
  }
  print("stills written to \(outDir.path)"); exit(0)
}

// ---- video mode
let L = LOOKS[lookName]!
let start = Double(opts["start"] ?? "0")!; let durOpt = opts["duration"].map { Double($0)! }
let totalDur = asset.duration.seconds - start
let dur = min(durOpt ?? totalDur, totalDur)
let reader = try! AVAssetReader(asset: asset)
reader.timeRange = CMTimeRange(start: CMTime(seconds: start, preferredTimescale: 600), duration: CMTime(seconds: dur, preferredTimescale: 600))
let rOut = AVAssetReaderTrackOutput(track: track, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
reader.add(rOut)

func makeWriter(_ name: String, bitrate: Int) -> (AVAssetWriter, AVAssetWriterInput, AVAssetWriterInputPixelBufferAdaptor) {
  let url = outDir.appendingPathComponent(name); try? FileManager.default.removeItem(at: url)
  let w = try! AVAssetWriter(outputURL: url, fileType: .mov)
  let i = AVAssetWriterInput(mediaType: .video, outputSettings: [
    AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: outW, AVVideoHeightKey: outH,
    AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: bitrate, AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel],
    AVVideoColorPropertiesKey: [AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
                                AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                                AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2]])
  i.expectsMediaDataInRealTime = false
  let ad = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: i, sourcePixelBufferAttributes: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
    kCVPixelBufferWidthKey as String: outW, kCVPixelBufferHeightKey as String: outH])
  w.add(i); return (w, i, ad)
}
let (gW, gIn, gAd) = makeWriter("graded.mov", bitrate: 16_000_000)
let (mW, mIn, mAd) = makeWriter("matte.mov", bitrate: 6_000_000)
reader.startReading()
for w in [gW, mW] { w.startWriting(); w.startSession(atSourceTime: .zero) }
let seq = VNSequenceRequestHandler()

func orient(_ img: CIImage) -> CIImage { fit(img.transformed(by: track.preferredTransform)) }
func append(_ img: CIImage, _ inp: AVAssetWriterInput, _ ad: AVAssetWriterInputPixelBufferAdaptor, _ t: CMTime) {
  while !inp.isReadyForMoreMediaData { usleep(2000) }
  var dst: CVPixelBuffer?
  CVPixelBufferPoolCreatePixelBuffer(nil, ad.pixelBufferPool!, &dst)
  ctx.render(img, to: dst!, bounds: CGRect(x: 0, y: 0, width: outW, height: outH), colorSpace: rec709)
  ad.append(dst!, withPresentationTime: t)
}

let total = Int(Double(fps) * dur); var n = 0
let t0 = Date()
while let sb = rOut.copyNextSampleBuffer() {
  autoreleasepool {
    let pts = CMTimeSubtract(CMSampleBufferGetPresentationTimeStamp(sb), CMTime(seconds: start, preferredTimescale: 600))
    let src = orient(CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(sb)!))
    let (g, m) = grade(src, L, seq: seq, fade: true)
    append(g, gIn, gAd, pts); append(m, mIn, mAd, pts)
    n += 1
    if n % 30 == 0 { print(String(format: "frame %d/%d  %.1f fps", n, total, Double(n) / Date().timeIntervalSince(t0))); fflush(stdout) }
  }
}
gIn.markAsFinished(); mIn.markAsFinished()
let done = DispatchGroup()
for w in [gW, mW] { done.enter(); w.finishWriting { done.leave() } }
done.wait()
print("done \(n) frames \(outW)x\(outH) look=\(lookName) -> \(outDir.path)  status \(gW.status.rawValue)/\(mW.status.rawValue) \(gW.error?.localizedDescription ?? "")")
