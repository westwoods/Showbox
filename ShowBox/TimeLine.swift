//
//  TimeLineStruct.swift
//  ShowBox
//
//  Created by snow on 2017. 8. 4..
//  Copyright © 2017년 snow. All rights reserved.
//

import AVFoundation
import Photos
import Foundation
public class TimeAsset{
	public enum AssetType {
		case photo,video,livePhoto,music,unknown
	}
	public enum SelectedHighLight {
		case selected, highLighted, none
	}
	public enum FaceFeatures {
		case none , eye, smile, many
	}
	var passet:UIImage?
	let aAsset:AVAudioMix?
	let musicAsset:AVAsset?
	var vAsset:AVAsset?
	var type: AssetType = .unknown
	var timeStart:CMTime
	var timePlayEnd:CMTime?
	var timeDelayEnd:CMTime
	
	public var selectedOrder: Int = 0
	public var selectedHighLight: SelectedHighLight = .none  //0 nomal 1 selected 2 highlighted
	public var faces:[FaceFeatures] = []
	
	init (timeStart : CMTime,  timePlayEnd : CMTime?, timeDelayEnd : CMTime,		passet :UIImage? = nil, vAsset:AVAsset? = nil, musicAsset:AVAsset? = nil, aAsset:AVAudioMix? = nil, type:AssetType = AssetType.unknown){
		self.timeStart = timeStart
		self.timePlayEnd = timePlayEnd
		self.timeDelayEnd = timeDelayEnd
		self.passet = passet
		self.aAsset = aAsset
		self.vAsset = vAsset
		self.musicAsset = musicAsset
	}
}


class VideoTime:TimeAsset{
	init (timeStart: CMTime, timePlayEnd: CMTime?, timeDelayEnd: CMTime, vAsset: AVAsset?){
		super.init(timeStart: timeStart, timePlayEnd: timePlayEnd, timeDelayEnd: timeDelayEnd, vAsset: vAsset)
		
		self.type = AssetType.video
	}
}

public class MusicTime:TimeAsset{
	var musicName: String = ""
	var coverImage:UIImage? = nil
	var url:URL? = nil
	init (timeStart: CMTime, timePlay: CMTime?, timeEnd: CMTime, musicAsset: AVAsset?,musicName:String, coverImage:UIImage?, url:URL?){
		super.init(timeStart: timeStart, timePlayEnd: timePlay, timeDelayEnd: timeEnd, musicAsset: musicAsset)
		self.url = url
		self.coverImage = coverImage
		self.musicName = musicName
		self.type = AssetType.music
	}
}

class ImageTime:TimeAsset{
	init (timeStart: CMTime, timePlayEnd: CMTime, asset: UIImage, faces:[FaceFeatures])
	{
		super.init(timeStart: timeStart, timePlayEnd: timePlayEnd, timeDelayEnd: kCMTimeInvalid)
		self.type = AssetType.photo
		self.passet = asset
		self.faces = faces
	}
}


public class   TimeLine{
	public func getTimes()->[TimeAsset]{
		return myTimes
	}
	
	lazy var imageManager = {
		return PHCachingImageManager()
	}()
	var myTimes:[TimeAsset] = []
	var	selectedAssets:[TLPHAsset] = []
	var complete:(()->())? = nil
	public var myBGM:MusicTime?
	
	public var defaultBGM:MusicTime?
	var semaphore:DispatchSemaphore = DispatchSemaphore(value: 0)
	//초기딜레이가 시작한시간~ // 영상이 시작한 시간 // 영상이 끝난시간 // 후기딜레이가 끝난시간 == 다음영상의 초기딜레이 시작
	
	
	init()
	{
		
		let thisBundle = Bundle(for: type(of: self))
		let url = thisBundle.url(forResource: "Splashing_Around", withExtension: "mp3")
		let splashign_Around = AVAsset(url: url!)
		let music = MusicTime.init(timeStart: kCMTimeZero, timePlay: CMTimeAdd(kCMTimeZero, CMTime(seconds: 154.749, preferredTimescale: 44100)), timeEnd: CMTimeAdd(kCMTimeZero, CMTime(seconds: 154.749, preferredTimescale: 44100)), musicAsset: splashign_Around, musicName: "Aplashing_Around", coverImage: #imageLiteral(resourceName: "Atlanta.jpeg"),url: url)
		myBGM = music
		defaultBGM = music
		//TODO
	}
	
	public func makeTimeLine(selectedAssets:[TLPHAsset],complete:@escaping (()->()) ){
		
		let nextDelayTime:TimeInterval = 2
		var startTime:CMTime = kCMTimeZero
		let nextDelay:CMTime = CMTimeMakeWithSeconds(nextDelayTime, 3000000);
		semaphore = DispatchSemaphore(value: 0)
		self.selectedAssets = selectedAssets
		self.complete = complete
		
		let thisBundle = Bundle(for: type(of: self))
		let introAsset = AVAsset(url:  thisBundle.url(forResource: "intro", withExtension: "MOV")!)
		let intro = VideoTime(timeStart: startTime, timePlayEnd:kCMTimeZero, timeDelayEnd: kCMTimeZero, vAsset:introAsset)
		self.myTimes.append(	intro)
		var latestVideo:VideoTime = intro
		for i in 0..<selectedAssets.count
		{
			let temp = selectedAssets[i]
			if temp.type == TLPHAsset.AssetType.video{
				let options = PHVideoRequestOptions()
				imageManager.requestAVAsset(forVideo: temp.phAsset!, options: options, resultHandler: { (AVAsset, AVAudioMix, info) in
					latestVideo.timeDelayEnd = startTime // 이전 영상이 다음 영상의 시작 시간까지 담당.
					
					debugPrint("TD Lvideo start", latestVideo.timeStart,"\n")
					debugPrint("TD Lvideo dend", latestVideo.timeDelayEnd,"\n")

					let nextVideo = VideoTime(timeStart: startTime, timePlayEnd:CMTimeAdd(startTime, (AVAsset?.duration)!), timeDelayEnd: kCMTimeInvalid, vAsset: AVAsset)
					self.myTimes.append(	nextVideo )
					
					debugPrint("TD Nvideo start", nextVideo.timeStart,"\n")
					debugPrint("TD Nvideo dend", nextVideo.timeDelayEnd,"\n")
					latestVideo = nextVideo
					startTime = CMTimeAdd(startTime, (AVAsset?.duration)!)
					self.semaphore.signal()
				})
				semaphore.wait()
			}
			else{
				if temp.type == TLPHAsset.AssetType.photo{
					myTimes.append(ImageTime(timeStart: startTime, timePlayEnd: CMTimeAdd(startTime, nextDelay), asset: temp.fullResolutionImage!,faces:temp.faceFeatureFilter))
					debugPrint("TDphoto start", startTime,"\n")
					startTime = CMTimeAdd(startTime, nextDelay)
					latestVideo.timeDelayEnd = startTime
					debugPrint("TDphoto end",startTime,"\n")
				}
				else if(temp.type == TLPHAsset.AssetType.livePhoto){
					print("라이브 포토는 이미지와 영상이 합쳐진 형태임.")
				}
			}
		}
		
		debugPrint("TD Lvideo start", latestVideo.timeStart,"\n")
		debugPrint("TD Lvideo dend", latestVideo.timeDelayEnd,"\n")
		//세마포 걸어야될수도잇음.
		if myBGM != nil{
			print ("음악있음")
			complete()
		}
	}
	
	public func removeAll(){
		myTimes.removeAll()
		selectedAssets.removeAll()
		myBGM = defaultBGM
	}
}
