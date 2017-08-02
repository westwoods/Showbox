import UIKit

open class FaceDetector{
    
   class  func detect(uiImage: UIImage)  -> [CIFeature]? {
        let imageOptions = [CIDetectorSmile : true ,CIDetectorEyeBlink: true]
        let personciImage = CIImage(cgImage: uiImage.cgImage!)
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyLow]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage, options: imageOptions )
    
        if  ((faces?.first) != nil) {
            return faces
        } else {
            return nil
        }
    }
    
}
