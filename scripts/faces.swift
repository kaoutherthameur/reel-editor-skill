// Face box + nose + eyes for every PNG in a folder -> <folder>/../faces.json (top-left origin pixels).
// usage: swift faces.swift <frames_dir>
import Foundation
import Vision
import CoreImage
let dir = CommandLine.arguments[1]
let files = try! FileManager.default.contentsOfDirectory(atPath: dir).filter { $0.hasSuffix(".png") }.sorted()
var out: [[String: Any]] = []
func pts(_ r: VNFaceLandmarkRegion2D?, _ b: CGRect, _ W: Double, _ H: Double) -> [[Double]] {
  var a: [[Double]] = []
  for p in r?.normalizedPoints ?? [] {
    let x: Double = Double(b.minX + p.x * b.width) * W
    let y: Double = (1.0 - Double(b.minY + p.y * b.height)) * H
    a.append([x, y])
  }
  return a
}
for f in files {
  let ci = CIImage(contentsOf: URL(fileURLWithPath: dir + "/" + f))!
  let W = Double(ci.extent.width), H = Double(ci.extent.height)
  let req = VNDetectFaceLandmarksRequest()
  try! VNImageRequestHandler(ciImage: ci).perform([req])
  var j: [String: Any] = ["f": f]
  if let r = req.results?.first {
    let b = r.boundingBox
    let bx: Double = Double(b.minX) * W, by: Double = (1 - Double(b.maxY)) * H, bw: Double = Double(b.width) * W, bh: Double = Double(b.height) * H
    j["box"] = [bx, by, bw, bh]
    j["nose"] = pts(r.landmarks?.nose, b, W, H)
    j["eyes"] = pts(r.landmarks?.leftEye, b, W, H) + pts(r.landmarks?.rightEye, b, W, H)
  }
  out.append(j)
}
try! JSONSerialization.data(withJSONObject: out).write(to: URL(fileURLWithPath: dir + "/../faces.json"))
print("faces", out.count)
