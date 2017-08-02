import UIKit

open class FaceDetector{
    
   class  func detect(uiImage: UIImage)  -> CIFaceFeature? {
        let imageOptions = [CIDetectorSmile : true ,CIDetectorEyeBlink: true]
        let personciImage = CIImage(cgImage: uiImage.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage, options: imageOptions )
        
        if let face = faces?.first as? CIFaceFeature {
            print("found bounds are \(face.bounds)")
            
            if face.hasSmile {
                print("face is smiling");
            }
            
            if face.hasLeftEyePosition {
                print("Left eye bounds are \(face.leftEyePosition)")
            }
            
            if face.hasRightEyePosition {
                print("Right eye bounds are \(face.rightEyePosition)")
            }
            return face
        } else {
            return nil
        }
    }
    
}
