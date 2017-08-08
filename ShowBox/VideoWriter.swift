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
	
	class func mergeVideo(_ myVideoAsset:[AVAsset],myPhotoAsset:[UIImage])
	{
		let myMutableComposition:AVMutableComposition = AVMutableComposition()
		
		let videoCompositionTrack:AVMutableCompositionTrack
			= myMutableComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID:  kCMPersistentTrackID_Invalid)
		//        let audioCompositionTrack:AVMutableCompositionTrack =
		//            myMutableComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID:  kCMPersistentTrackID_Invalid)
		let nextDelayTime:TimeInterval = 5
		var startTime:CMTime = kCMTimeZero
		let nextDelay:CMTime = CMTimeMakeWithSeconds(nextDelayTime, 1000000);
		
		startTime = CMTimeAdd(startTime,nextDelay)
		var renderSize:CGSize = CGSize.init(width: 0, height: 0)
		let mutableVideoCompositon = AVMutableVideoComposition.init()
		
		var VideoCompositionInsturction:AVMutableVideoCompositionInstruction? = nil
		for Index in 0..<myVideoAsset.count{
			let assetDuration = myVideoAsset[Index].duration
			let assetDurationWithNextDelay = CMTimeAdd(assetDuration, nextDelay)
			let videoAssetTrack:AVAssetTrack = myVideoAsset[Index].tracks(withMediaType: AVMediaTypeVideo)[0]
			//렌더링 사이즈 결정
			if renderSize.width < videoAssetTrack.naturalSize.width{
				renderSize.width = videoAssetTrack.naturalSize.width
			}
			if renderSize.height < videoAssetTrack.naturalSize.height{
				renderSize.height = videoAssetTrack.naturalSize.height
			}
			
			do{
				try videoCompositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,assetDurationWithNextDelay),of:videoAssetTrack, at:startTime)
			}
			catch{
			}
			//  인스트럭션 결정
			if VideoCompositionInsturction == nil {
				VideoCompositionInsturction = AVMutableVideoCompositionInstruction.init()
				VideoCompositionInsturction!.timeRange = CMTimeRangeMake(kCMTimeZero,CMTimeAdd(assetDurationWithNextDelay,startTime))
			}
			else{
				VideoCompositionInsturction = AVMutableVideoCompositionInstruction.init()
				VideoCompositionInsturction!.timeRange = CMTimeRangeMake(startTime,assetDurationWithNextDelay)
			}
			let VideoLayerInstruction =
				AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
			// VideoLayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: startTime)
			
			VideoCompositionInsturction!.layerInstructions = [VideoLayerInstruction]
			mutableVideoCompositon.instructions.append(VideoCompositionInsturction!)
			
			
			startTime = CMTimeAdd(startTime, assetDurationWithNextDelay)
		}
		if(myPhotoAsset.count > 0){
			VideoWriter.over(renderSize, layercomposition: mutableVideoCompositon,  photosToOverlay: myPhotoAsset)
		}
		mutableVideoCompositon.renderSize = renderSize
		// Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
		mutableVideoCompositon.frameDuration = CMTimeMake(1,30);
		
		
		let session:AVAssetExportSession? = AVAssetExportSession(asset: myMutableComposition, presetName: AVAssetExportPresetHighestQuality)
		
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		
		let exportURL = URL(fileURLWithPath: (paths + "/move3.mov"))
		do{
			try VideoWriter.deleteExistingFile(exportURL)
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
				else if session.status == AVAssetExportSessionStatus.failed{
					print("Export Error: \(session.error ?? "ERR" as! Error)")
					print("Export Failed")
				}
				else{
					print("Export Cancelled")
				}
			})
			
		}
	}
	class func exportAsset(_ asset: AVAsset) {
		let today = Date() //현재 시각 구하기
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yy_M_d_hh:mm:ss"
		let dateString = dateFormatter.string(from: today as Date)
		
		
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		
		let exportURL = URL(fileURLWithPath: (paths + "/"+dateString+".mov"))
		do{
			try VideoWriter.deleteExistingFile(exportURL)
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
	
	class func over(_ size:CGSize,layercomposition:AVMutableVideoComposition,photosToOverlay:[UIImage]){
		let size = size
		print(photosToOverlay.count)
		let today = Date() //현재 시각 구하기
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yy_M_d_hh:mm:ss"
		let dateString = dateFormatter.string(from: today as Date)
		
		// create text Layer
		let titleLayer = CATextLayer()
		titleLayer.backgroundColor = UIColor.clear.cgColor
		titleLayer.string = "한글 텍스트도 되나 확인을 하자"+dateString
		titleLayer.font = UIFont(name: "Helvetica", size: 288)
		titleLayer.foregroundColor = UIColor.black.cgColor
		titleLayer.shadowOpacity = 0.0
		titleLayer.alignmentMode = kCAAlignmentCenter
		titleLayer.frame = CGRect(x:0, y:0, width:size.width, height:size.height )
		
		let videolayer = CALayer()
		videolayer.frame = CGRect(x:0, y:0, width:size.width, height:size.height )
		let parentlayer = CALayer()
		parentlayer.frame = CGRect(x:0, y:0, width:size.width, height:size.height )
		parentlayer.addSublayer(videolayer)
		parentlayer.addSublayer(titleLayer)
		for i in 0..<photosToOverlay.count
		{
			
			let imglogo:UIImage? = photosToOverlay[i]
			
			
			let imglayer = CALayer()
			imglayer.contents = imglogo?.cgImage
			imglayer.frame = CGRect(x:0, y:0, width:size.width, height:size.height)
			imglayer.masksToBounds = true
			imglayer.opacity = 0
			imglayer.backgroundColor = UIColor.blue.cgColor
			parentlayer.addSublayer(imglayer)
			
			let myanimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
			myanimation.fromValue = imglayer.opacity
			myanimation.toValue = 1
			myanimation.duration = 1.0
			myanimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
			myanimation.autoreverses  = true
			myanimation.beginTime = AVCoreAnimationBeginTimeAtZero + Double(i)
			//myanimation.isRemovedOnCompletion = false //애니메이션이 종료되어도 애니메이션을 지우지않는다.
			//myanimation.fillMode = kCAFillModeForwards //애니메이션이 종료된뒤 계속해서 상태를 유지한다.
			imglayer.add(myanimation, forKey: "opacity")
		}
		let layercomposition = layercomposition
		layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
		
	}
	
	class func deleteExistingFile(_ destinationURL: URL) throws {
		let fileManager = FileManager()
		
		let destinationPath = destinationURL.path
		if fileManager.fileExists(atPath: destinationPath) {
			print("Removing pre-existing file at destination path \"\(destinationPath)\".")
			
			try fileManager.removeItem(at: destinationURL)
			
		}
	}
	
}
