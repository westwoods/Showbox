import UIKit



open class FaceDetector{
	
	func imageOrientationToExif(image: UIImage) -> uint {
		switch image.imageOrientation {
		case UIImageOrientation.up:
			return 1;
		case UIImageOrientation.down:
			return 3;
		case UIImageOrientation.left:
			return 8;
		case UIImageOrientation.right:
			return 6;
		case UIImageOrientation.upMirrored:
			return 2;
		case UIImageOrientation.downMirrored:
			return 4;
		case UIImageOrientation.leftMirrored:
			return 5;
		case UIImageOrientation.rightMirrored:
			return 7;
		}
	}
	static let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyLow]
	static let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
	
	func detect(uiImage: UIImage)  -> [CIFeature]? {
		var faces:[CIFeature]? = nil
		//TODO 이미지 방향이나 해상도에 관련한 이슈가 있음. 가로모드 세로모드에 따라 인식에 차이가있음.
		let sourceOrientation = self.imageOrientationToExif(image: uiImage)
		let imageOptions:[String:Any] = [CIDetectorSmile : true ,CIDetectorEyeBlink: true, CIDetectorImageOrientation: sourceOrientation]
		//	print(sourceOrientation)
		var personciImage:CIImage? = CIImage.init(image: uiImage)
		faces = FaceDetector.faceDetector?.features(in: personciImage!, options: imageOptions)
		if faces?.count == 0{
			return nil
		}
		else{
			return faces
		}
	}
}
