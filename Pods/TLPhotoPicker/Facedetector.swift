import UIKit
open class FaceDetector{
    
static  let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyLow]
static  let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
//faceDetector가 데이터를 저장해서 새로운 디텍터를 만들기보다는 같은것을 계속사용하는것을 추천함
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
