//
//  VideoWriter.swift
//  test01
//
//  Created by snow on 2017. 7. 27..
//  Copyright © 2017년 snow. All rights reserved.
//

import Foundation
import Photos
import AVFoundation
import AssetsLibrary

class VideoWriter {
    
    class func mergeVideo(myVideoAsset:[AVAsset],myPhotoAsset:[UIImage])
    {
        let myPhotoAsset = myPhotoAsset
        print (myPhotoAsset.count)
        let myMutableComposition:AVMutableComposition = AVMutableComposition()
        
        let videoCompositionTrack:AVMutableCompositionTrack
            = myMutableComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID:  kCMPersistentTrackID_Invalid)
        //        let audioCompositionTrack:AVMutableCompositionTrack =
        //            myMutableComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID:  kCMPersistentTrackID_Invalid)
        //
        let videoAssetTrack0:AVAssetTrack = myVideoAsset[0].tracks(withMediaType: AVMediaTypeVideo)[0]
        print ("myvideo count",videoAssetTrack0.asset?.duration ?? "골로간다" ,videoAssetTrack0.timeRange.duration)
        
        let videoAssetTrack1:AVAssetTrack = myVideoAsset[1].tracks(withMediaType: AVMediaTypeVideo)[0]
        
        do{
            
            try videoCompositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack0.timeRange.duration),of:videoAssetTrack0, at:kCMTimeZero)
            
            
            try  videoCompositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack1.timeRange.duration),of:videoAssetTrack1, at:videoAssetTrack0.timeRange.duration)
            //
            //    try audioCompositionTrack.insertTimeRange(
            //            CMTimeRangeMake(kCMTimeZero,CMTimeAdd( videoAssetTrack0.timeRange.duration,  videoAssetTrack1.timeRange.duration)),of:myAudioAsset[0].,at:kCMTimeZero)
            
        }
        catch{
            print ("errooo\n")
        }
        
        let firstVideoCompositionInsturction = AVMutableVideoCompositionInstruction.init()
        firstVideoCompositionInsturction.timeRange = CMTimeRangeMake(kCMTimeZero,videoAssetTrack0.timeRange.duration)
        
        let secondVideoCompositionInsturction = AVMutableVideoCompositionInstruction.init()
        secondVideoCompositionInsturction.timeRange = CMTimeRangeMake(videoAssetTrack0.timeRange.duration,CMTimeAdd( videoAssetTrack0.timeRange.duration,  videoAssetTrack1.timeRange.duration) )
        
        
        
        let firstVideoLayerInstruction =
            AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        
        firstVideoLayerInstruction.setTransform(videoAssetTrack0.preferredTransform, at: kCMTimeZero)
        
        let secondVideoLayerInstruction =
            AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        secondVideoLayerInstruction.setTransform(videoAssetTrack1.preferredTransform, at: videoAssetTrack0.timeRange.duration)
        
        
        firstVideoCompositionInsturction.layerInstructions = [firstVideoLayerInstruction]
        secondVideoCompositionInsturction.layerInstructions = [secondVideoLayerInstruction]
        let mutableVideoCompositon = AVMutableVideoComposition.init()
        mutableVideoCompositon.instructions = [firstVideoCompositionInsturction,secondVideoCompositionInsturction]
        
        //5 랜더링 사이즈 결정
        var naturalSizeFirst, naturalSizeSecond:CGSize
        naturalSizeFirst = videoAssetTrack0.naturalSize;
        naturalSizeSecond = videoAssetTrack1.naturalSize;
        var renderWidth, renderHeight:CGFloat
        // Set the renderWidth and renderHeight to the max of the two videos widths and heights.
        if (naturalSizeFirst.width > naturalSizeSecond.width) {
            renderWidth = naturalSizeFirst.width;
        }
        else {
            renderWidth = naturalSizeSecond.width;
        }
        if (naturalSizeFirst.height > naturalSizeSecond.height) {
            renderHeight = naturalSizeFirst.height;
        }
        else {
            renderHeight = naturalSizeSecond.height;
        }
     VideoWriter.over(size: CGSize(width: renderWidth, height: renderHeight), layercomposition: mutableVideoCompositon,  photosToOverlay: myPhotoAsset)
        
        mutableVideoCompositon.renderSize = CGSize(width: renderWidth, height: renderHeight)
        // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
        mutableVideoCompositon.frameDuration = CMTimeMake(1,30);
        
        
        let session:AVAssetExportSession? = AVAssetExportSession(asset: myMutableComposition, presetName: AVAssetExportPresetHighestQuality)
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let exportURL = URL(fileURLWithPath: (paths + "/move3.mov"))
        do{
            try VideoWriter.deleteExistingFile(destinationURL: exportURL)
        }catch {
            print("THERE IS NO FILE")
        }
        if let session = session
        {
            session.outputURL = exportURL
            session.outputFileType = AVFileTypeQuickTimeMovie
            //session.shouldOptimizeForNetworkUse = true
            session.videoComposition = mutableVideoCompositon
            session.exportAsynchronously(completionHandler: {
                print("Output File Type: \(session.outputFileType ?? "FILE TYPE MIA")")
                print("Output URL: \(session.outputURL?.absoluteString ?? "URL MIA")")
                print("Video Compatible W/ Camera Roll: \(session.asset.isCompatibleWithSavedPhotosAlbum)")
                //-----SAVE-----
                if session.status == AVAssetExportSessionStatus.completed
                {
                    print("Export Finished")
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportURL)
                    }) { saved, error in
                        if saved {
                            print("Saved")
                        }
                        else{
                            print(error as Any)
                        }
                    }
                }
                else if session.status == AVAssetExportSessionStatus.failed
                {
                    print("Export Error: \(session.error ?? "ERR" as! Error)")
                    print("Export Failed")
                }
                else
                {
                    print("Export Cancelled")
                }
            })
            
        }
    }
    class func exportAsset(asset: AVAsset) {
        let today = NSDate() //현재 시각 구하기
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy_M_d_hh:mm:ss"
        let dateString = dateFormatter.string(from: today as Date)
        
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let exportURL = URL(fileURLWithPath: (paths + "/"+dateString+".mov"))
        do{
            try VideoWriter.deleteExistingFile(destinationURL: exportURL)
        }catch {
            print("THERE IS NO FILE")
        }
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetLowQuality)
        exporter?.outputURL = exportURL
        exporter?.outputFileType = AVFileTypeQuickTimeMovie
        exporter?.exportAsynchronously(completionHandler: {
            
            
            print("Output File Type: \(exporter?.outputFileType ?? "FILE TYPE MIA")")
            print("Output URL: \(exporter?.outputURL?.absoluteString ?? "URL MIA")")
            print("Video Compatible W/ Camera Roll: \(exporter!.asset.isCompatibleWithSavedPhotosAlbum)")
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportURL)
            }) { saved, error in
                if saved {
                    print("Saved")
                }
            }
        })
    }
    
    class func over(size:CGSize,layercomposition:AVMutableVideoComposition,photosToOverlay:[UIImage]){
        let size = size
        print(photosToOverlay.count)
            let imglogo:UIImage? = photosToOverlay[0]
            let imglayer = CALayer()
            imglayer.contents = imglogo?.cgImage
            imglayer.frame = CGRect(x:0, y:0, width:size.width, height:size.height)
            imglayer.opacity = 1
         //   imglayer.backgroundColor = UIColor.blue.cgColor
            
            // create text Layer
            let titleLayer = CATextLayer()
            titleLayer.backgroundColor = UIColor.white.cgColor
            titleLayer.string = "한글 텍스트도 되나 확인을 하자"
            titleLayer.font = UIFont(name: "Helvetica", size: 288)
            titleLayer.foregroundColor = UIColor.blue.cgColor
            titleLayer.shadowOpacity = 0.5
            titleLayer.alignmentMode = kCAAlignmentCenter
            titleLayer.frame = CGRect(x:0, y:50, width:size.width, height:size.height / 6)
            
            let videolayer = CALayer()
            videolayer.frame = CGRect(x:0, y:0, width:size.width, height:size.height )
            let parentlayer = CALayer()
            parentlayer.frame = CGRect(x:0, y:0, width:size.width, height:size.height )
            parentlayer.addSublayer(videolayer)
            parentlayer.addSublayer(imglayer)
            parentlayer.addSublayer(titleLayer)
            let myanimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
            
            myanimation.fromValue = imglayer.opacity
            
            myanimation.toValue = 0
            
        //    myanimation.autoreverses=true
            myanimation.duration = 2.0
            myanimation.beginTime = AVCoreAnimationBeginTimeAtZero
            
            parentlayer.add(myanimation, forKey: "opacity")
            let layercomposition = layercomposition
            layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
            

        

}
    
class func deleteExistingFile(destinationURL: URL) throws {
        let fileManager = FileManager()
        
        let destinationPath = destinationURL.path
        if fileManager.fileExists(atPath: destinationPath) {
            print("Removing pre-existing file at destination path \"\(destinationPath)\".")
            
            try fileManager.removeItem(at: destinationURL)
            
        }
    }
    
}
