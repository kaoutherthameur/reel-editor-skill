import Foundation; import CoreImage; import CoreImage.CIFilterBuiltins; import Vision; import AppKit
let a = CommandLine.arguments; let inp = CIImage(contentsOf: URL(fileURLWithPath: a[1]))!; let dir = a[2]
let ext = inp.extent; let ctx = CIContext()
let req = VNGeneratePersonSegmentationRequest(); req.qualityLevel = .accurate; req.outputPixelFormat = kCVPixelFormatType_OneComponent8
try! VNImageRequestHandler(ciImage: inp).perform([req])
var mask = CIImage(cvPixelBuffer: req.results!.first!.pixelBuffer)
mask = mask.transformed(by: CGAffineTransform(scaleX: ext.width/mask.extent.width, y: ext.height/mask.extent.height)).clampedToExtent().applyingGaussianBlur(sigma: 3).cropped(to: ext)
func save(_ i: CIImage, _ n: String) { let cs = CGColorSpace(name: CGColorSpace.sRGB)!; try! ctx.writePNGRepresentation(of: i.cropped(to: ext), to: URL(fileURLWithPath: "\(dir)/\(n).png"), format: .RGBA8, colorSpace: cs) }
func subj(_ ev: Float) -> CIImage {
  let e = CIFilter.exposureAdjust(); e.inputImage = inp; e.ev = ev
  let hs = CIFilter.highlightShadowAdjust(); hs.inputImage = e.outputImage; hs.highlightAmount = 0.85; hs.shadowAmount = 0.25
  let t = CIFilter.temperatureAndTint(); t.inputImage = hs.outputImage; t.neutral = CIVector(x: 6500, y: 0); t.targetNeutral = CIVector(x: 6700, y: 6)
  let v = CIFilter.vibrance(); v.inputImage = t.outputImage; v.amount = 0.12
  let s = CIFilter.sharpenLuminance(); s.inputImage = v.outputImage; s.sharpness = 0.3
  return s.outputImage! }
func curve(_ i: CIImage) -> CIImage { let c = CIFilter.toneCurve(); c.inputImage = i
  c.point0 = CGPoint(x:0,y:0.01); c.point1 = CGPoint(x:0.25,y:0.21); c.point2 = CGPoint(x:0.5,y:0.5); c.point3 = CGPoint(x:0.75,y:0.79); c.point4 = CGPoint(x:1,y:0.98); return c.outputImage! }
func blend(_ fg: CIImage, _ bg: CIImage) -> CIImage { let b = CIFilter.blendWithMask(); b.inputImage = fg; b.backgroundImage = bg; b.maskImage = mask; return b.outputImage! }
func bgv(ev: Float, sat: Float, temp: Float, blur: Double) -> CIImage {
  let e = CIFilter.exposureAdjust(); e.inputImage = inp.clampedToExtent(); e.ev = ev
  let c = CIFilter.colorControls(); c.inputImage = e.outputImage; c.saturation = sat
  let t = CIFilter.temperatureAndTint(); t.inputImage = c.outputImage; t.neutral = CIVector(x: 6500, y: 0); t.targetNeutral = CIVector(x: CGFloat(temp), y: 0)
  return t.outputImage!.applyingGaussianBlur(sigma: blur).cropped(to: ext) }
save(inp, "0_original")
// A: clean & airy: subject lifted, wall neutral/cool-white, soft blur
save(curve(blend(subj(0.35), bgv(ev: -0.1, sat: 0.55, temp: 7300, blur: 14))), "1_clean_airy")
// B: separation/moody: wall darker, cooler, blur
save(curve(blend(subj(0.3), bgv(ev: -0.9, sat: 0.6, temp: 7200, blur: 14))), "2_depth_darker_room")
// C: room replaced by grid world
let gridURL = URL(fileURLWithPath: "\(dir)/grid.png"); let grid = CIImage(contentsOf: gridURL)!
let sh = mask.applyingGaussianBlur(sigma: 40).transformed(by: CGAffineTransform(translationX: 0, y: -25)).cropped(to: ext)
let shadow = CIFilter.blendWithMask(); shadow.inputImage = CIImage(color: CIColor(red:0.05,green:0.08,blue:0.08,alpha:0.22)).cropped(to: ext); shadow.backgroundImage = grid; shadow.maskImage = sh
save(curve(blend(subj(0.2), shadow.outputImage!)), "3_grid_world")
print("ok")
