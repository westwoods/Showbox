import UIKit

open class FaceDetector{
	
	static let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyLow]
	static let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
	
	class  func detect(uiImage: UIImage)  -> [CIFeature]? {
		let imageOptions = [CIDetectorSmile : true ,CIDetectorEyeBlink: true]
		let personciImage = CIImage(cgImage: uiImage.cgImage!)
		let faces = faceDetector?.features(in: personciImage, options: imageOptions )
		
		if  ((faces?.first) != nil) {
			return faces
		} else {
			return nil
		}
	}
	
}
