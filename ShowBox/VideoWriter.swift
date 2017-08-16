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
	static var exportURL:URL? = nil
	class func mergeVideo(_ myTimeLine:TimeLine, previewSize:CGRect,complete:((AVComposition,AVMutableVideoComposition,CALayer)->())){
		let myMutableComposition:AVMutableComposition = AVMutableComposition()
		//*************************************트랙생성
		let videoCompositionTrack:AVMutableCompositionTrack
			= myMutableComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID:  kCMPersistentTrackID_Invalid)
		let audioCompositionTrack:AVMutableCompositionTrack =
			myMutableComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID:  kCMPersistentTrackID_Invalid)
		let BGMCompositionTrack:AVMutableCompositionTrack =
			myMutableComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID:  kCMPersistentTrackID_Invalid)
		//************************************트랙생성 끝
		
		let renderSize:CGSize = CGSize(width: 1024, height: 768)
		let mutableVideoCompositon = AVMutableVideoComposition.init()
		var VideoCompositionInsturction:AVMutableVideoCompositionInstruction? = nil
		print (myTimeLine.myTimes.count)
		let myTimes = myTimeLine.myTimes
		
		for Index in 0..<myTimes.count{
			print("index : ",Index)
			let myTime = myTimes[Index]
			if myTime.type == TimeAsset.AssetType.video{
				let videoAssetTrack:AVAssetTrack? = myTime.vAsset!.tracks(withMediaType: AVMediaTypeVideo).first
				let audioAssetTrack:AVAssetTrack? = myTime.vAsset!.tracks(withMediaType: AVMediaTypeAudio).first
				
				
				
				let videoDurationaddDelay = CMTimeSubtract(myTime.timeDelayEnd, myTime.timeStart)
				
				do{
					if let videoAssetTrack = videoAssetTrack{
						try videoCompositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,videoDurationaddDelay),of:videoAssetTrack, at:myTime.timeStart)}
					if let audioAssetTrack = audioAssetTrack{
						try audioCompositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,videoDurationaddDelay),of:audioAssetTrack, at:myTime.timeStart)
					}
					print("myTime. start  : ",myTime.timeStart , "\n myTime DelayEnd : ",myTime.timeDelayEnd)
					
				}
				catch{
				}
				//  인스트럭션 결정
				VideoCompositionInsturction = AVMutableVideoCompositionInstruction.init()
				VideoCompositionInsturction!.timeRange = CMTimeRangeMake(myTime.timeStart,videoDurationaddDelay)
				
				/*********영상 위치, 회전, 설정***********/
				let VideoLayerInstruction =
					AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
				var resizefactor = CGFloat(1.0)
				if (videoAssetTrack?.naturalSize.width)!/4 > (videoAssetTrack?.naturalSize.height)!/3{
					resizefactor = renderSize.width/(videoAssetTrack?.naturalSize.width)!
				}else{
					resizefactor = renderSize.height/(videoAssetTrack?.naturalSize.height)!
				}
				
				VideoLayerInstruction.setTransform((videoAssetTrack?.preferredTransform)!.scaledBy(x: resizefactor, y: resizefactor), at: myTime.timeStart)
				
				VideoCompositionInsturction!.layerInstructions = [VideoLayerInstruction]
				mutableVideoCompositon.instructions.append(VideoCompositionInsturction!)
			}
		}
		//배경음악
		let audioAssetTrack:AVAssetTrack =  (myTimeLine.myBGM?.musicAsset?.tracks(withMediaType: AVMediaTypeAudio)[0])!
		
		do{
			var audioLoopStartTime:CMTime = kCMTimeZero
			while(audioLoopStartTime < CMTimeSubtract(myTimeLine.timecut,(audioAssetTrack.asset?.duration)!)){ // 영상 끝까지 무한루프~
				try BGMCompositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,(audioAssetTrack.asset?.duration)!),of:audioAssetTrack, at:audioLoopStartTime)
				audioLoopStartTime = CMTimeAdd(audioLoopStartTime, (audioAssetTrack.asset?.duration)!)
			}
			try BGMCompositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,CMTimeSubtract(myTimeLine.timecut,audioLoopStartTime)),of:audioAssetTrack, at:audioLoopStartTime)
			//마지막 배경음악 조각
		}
		catch{
		}
		var previewlayer:CALayer = CALayer()
		mutableVideoCompositon.renderSize = renderSize
		print(mutableVideoCompositon.renderSize)
		mutableVideoCompositon.frameDuration = CMTimeMake(1,30);
		
		let MVCforpreView:AVMutableVideoComposition =	mutableVideoCompositon.mutableCopy() as! AVMutableVideoComposition
		//프리뷰를 위한 깊은 복사
		if( myTimes.count > 0){
			previewlayer = VideoWriter.preViewOverlay(previewSize, layercomposition: mutableVideoCompositon,  photosToOverlay: myTimes)
			VideoWriter.exportOverlay(CGRect(origin: CGPoint(x:0,y:0), size: renderSize), layercomposition: mutableVideoCompositon,  photosToOverlay: myTimes)
			
		}
		
		// Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
		
		let session:AVAssetExportSession? = AVAssetExportSession(asset: myMutableComposition, presetName: AVAssetExportPresetHighestQuality)
		
		/***/
		complete(myMutableComposition  , MVCforpreView, previewlayer)
		/***/
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		exportURL = URL(fileURLWithPath: (paths + "/move3.mov"))
		do{
			try VideoWriter.deleteExistingFile(exportURL!)
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
	class func saveToCameraRollAlbum(){
		if let exportURL = exportURL{
			print("저장 준비완료")
		PHPhotoLibrary.shared().performChanges({
			PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportURL)
		}) { saved, error in
			if saved { print("Saved")}
			else{ print(error as Any)}
		}
		}
		else{
			print("저장할 파일이 없음.")
		}
	}
	class func preViewOverlay(_ size:CGRect,layercomposition:AVMutableVideoComposition,photosToOverlay:[TimeAsset])->CALayer{
		let size = size
		print(photosToOverlay.count)
		let today = Date() //현재 시각 구하기
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yy_M_d_hh:mm:ss"
		let dateString = dateFormatter.string(from: today as Date)
		
		// create text Layer
		
		let videolayer = CALayer()
		videolayer.frame = size
		let parentlayer = CALayer()
		parentlayer.frame = size
		parentlayer.addSublayer(videolayer)
		for i in 0..<photosToOverlay.count
		{
			
			let tempPhoto = photosToOverlay[i]
			if tempPhoto.type == TimeAsset.AssetType.photo{
				
				let imglogo:UIImage? = tempPhoto.passet
				var resizefactor = CGFloat(1.0)
				if (imglogo?.size.width)!/4 > (imglogo?.size.height)!/3{
					resizefactor = size.width/(imglogo?.size.width)!
				}else{
					resizefactor = size.height/(imglogo?.size.height)!
				}
				let imglayer = CALayer()
				imglayer.contents = imglogo?.cgImage
				imglayer.frame = CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: ((imglogo?.size.width)!*resizefactor), height: ((imglogo?.size.height)!*resizefactor)))
				imglayer.position = CGPoint(x:parentlayer.bounds.midX , y:parentlayer.bounds.midY)
				imglayer.masksToBounds = true
				imglayer.opacity = 1.0
				imglayer.backgroundColor = UIColor.blue.cgColor
				
//				let myanimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
//				myanimation.fromValue = imglayer.opacity
//				myanimation.toValue = 1
//				myanimation.duration = (tempPhoto.timePlayEnd.seconds - tempPhoto.timeStart.seconds)/2
//				myanimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//				myanimation.autoreverses  = true
//				myanimation.beginTime = AVCoreAnimationBeginTimeAtZero + tempPhoto.timeStart.seconds
//				
//				myanimation.isRemovedOnCompletion = false //애니메이션이 종료되어도 애니메이션을 지우지않는다.
//				myanimation.fillMode = kCAFillModeForwards //애니메이션이 종료된뒤 계속해서 상태를 유지한다.
//				imglayer.add(myanimation, forKey: "opacity")
//				
				let myanimation:CABasicAnimation = CABasicAnimation(keyPath: "affineTransform")
				myanimation.fromValue = imglayer.affineTransform()
				myanimation.toValue = imglayer.affineTransform().scaledBy(x: 2.0, y: 2.0)
				myanimation.duration = (tempPhoto.timePlayEnd.seconds - tempPhoto.timeStart.seconds)/2
				myanimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
				myanimation.autoreverses  = true
				myanimation.beginTime = AVCoreAnimationBeginTimeAtZero + tempPhoto.timeStart.seconds
				
			//	myanimation.isRemovedOnCompletion = false //애니메이션이 종료되어도 애니메이션을 지우지않는다.
			//	myanimation.fillMode = kCAFillModeForwards //애니메이션이 종료된뒤 계속해서 상태를 유지한다.
				imglayer.add(myanimation, forKey: "affineTransform")
//				
//				let transition = CATransition()
//				transition.type = kCATransitionPush
//				transition.subtype = kCATransitionFromRight
//				transition.duration = (tempPhoto.timePlayEnd.seconds - tempPhoto.timeStart.seconds)/2
//				transition.beginTime =  AVCoreAnimationBeginTimeAtZero + tempPhoto.timeStart.seconds
//				transition.autoreverses = true
//				transition.isRemovedOnCompletion = false //애니메이션이 종료되어도 애니메이션을 지우지않는다.
//				transition.fillMode = kCAFillModeForwards //애니메이션이 종료된뒤 계속해서 상태를 유지한다.
//				imglayer.add(transition, forKey: "transition")
				parentlayer.addSublayer(imglayer)
				
				
				if let location = LocalDic[tempPhoto.locationGroup!]{
				let titleLayer = CATextLayer()
				titleLayer.backgroundColor = UIColor.clear.cgColor
				titleLayer.string = location + dateString
				titleLayer.font = UIFont(name: "HelveticaNeue-Bold", size: 40)
				titleLayer.fontSize = 15
				titleLayer.foregroundColor = UIColor.black.cgColor
				titleLayer.shadowOpacity = 0.0
				titleLayer.alignmentMode = kCAAlignmentCenter
				titleLayer.frame = size
					
					
				imglayer.addSublayer(titleLayer)
				}
			}
		}
		return parentlayer
	}
	
	
	class func exportOverlay(_ size:CGRect,layercomposition:AVMutableVideoComposition,photosToOverlay:[TimeAsset]){
		/*******************/
		let size = size
		print(photosToOverlay.count)
		let today = Date() //현재 시각 구하기
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yy_M_d_hh:mm:ss"
		let dateString = dateFormatter.string(from: today as Date)
		
		// create text Layer
		
		let videolayer = CALayer()
		videolayer.frame = size
		let parentlayer = CALayer()
		parentlayer.frame = size
		parentlayer.addSublayer(videolayer)
		for i in 0..<photosToOverlay.count
		{
			
			let tempPhoto = photosToOverlay[i]
			if tempPhoto.type == TimeAsset.AssetType.photo{
				
				let imglogo:UIImage? = tempPhoto.passet
				var resizefactor = CGFloat(1.0)
				if (imglogo?.size.width)!/4 > (imglogo?.size.height)!/3{
					resizefactor = size.width/(imglogo?.size.width)!
				}else{
					resizefactor = size.height/(imglogo?.size.height)!
				}
				let imglayer = CALayer()
				imglayer.contents = imglogo?.cgImage
				imglayer.frame = CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: ((imglogo?.size.width)!*resizefactor), height: ((imglogo?.size.height)!*resizefactor)))
				imglayer.position = CGPoint(x:parentlayer.bounds.midX , y:parentlayer.bounds.midY)
				imglayer.masksToBounds = true
				imglayer.opacity = 0.0
				imglayer.backgroundColor = UIColor.blue.cgColor
				
				let myanimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
				myanimation.fromValue = imglayer.opacity
				myanimation.toValue = 1
				myanimation.duration = (tempPhoto.timePlayEnd.seconds - tempPhoto.timeStart.seconds)/2
				myanimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
				myanimation.autoreverses  = true
				myanimation.beginTime = AVCoreAnimationBeginTimeAtZero + tempPhoto.timeStart.seconds
				
				myanimation.isRemovedOnCompletion = false //애니메이션이 종료되어도 애니메이션을 지우지않는다.
				myanimation.fillMode = kCAFillModeForwards //애니메이션이 종료된뒤 계속해서 상태를 유지한다.
				imglayer.add(myanimation, forKey: "opacity")
				
				parentlayer.addSublayer(imglayer)
				
				
				if let location = LocalDic[tempPhoto.locationGroup!]{
					let titleLayer = CATextLayer()
					titleLayer.backgroundColor = UIColor.clear.cgColor
					titleLayer.string = location + dateString
					titleLayer.font = UIFont(name: "HelveticaNeue-Bold", size: 40)
					titleLayer.fontSize = 15
					titleLayer.foregroundColor = UIColor.black.cgColor
					titleLayer.shadowOpacity = 0.0
					titleLayer.alignmentMode = kCAAlignmentCenter
					titleLayer.frame = size
					
					
					imglayer.addSublayer(titleLayer)
				}
			}
		}
		/******************************/
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
