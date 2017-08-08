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
	lazy var imageManager = {
		return PHCachingImageManager()
	}()
	public enum AssetType {
		case photo,video,livePhoto,music,unknown
	}
	public enum SelectedHighLight {
		case selected, highLighted, none
	}
	public enum FaceFeatures {
		case none , eye, smile, many
	}
	let asset:PHAsset?
	let aAsset:AVAsset?
	var vAsset:AVAsset?
	var type: AssetType = .unknown
	var timeStart:CMTime
	var timePlay:CMTime?
	var timeEnd:CMTime
	
	public var selectedOrder: Int = 0
	public var selectedHighLight: SelectedHighLight = .none  //0 nomal 1 selected 2 highlighted
	public var faces:[FaceFeatures] = []
	
	init (timeStart : CMTime,  timePlay : CMTime?, timeEnd : CMTime,		asset :PHAsset? = nil, vAsset:AVAsset? = nil, aAsset:AVAsset? = nil, type:AssetType = AssetType.unknown){
		self.timeStart = timeStart
		self.timePlay = timePlay
		self.timeEnd = timeEnd
		self.asset = asset
		self.aAsset = aAsset
		self.vAsset = vAsset
	}
}


class VideoTime:TimeAsset{
	init (timeStart: CMTime, timePlay: CMTime?, timeEnd: CMTime, asset: PHAsset?){
		super.init(timeStart: timeStart, timePlay: timePlay, timeEnd: timeEnd, asset: asset)
		
		let options = PHVideoRequestOptions()
		imageManager.requestAVAsset(forVideo: asset!, options: options, resultHandler: { (AVAsset, AVAudioMix, info) in self.vAsset = AVAsset
		})
	}
}

public class MusicTime:TimeAsset{
	var musicName: String = ""
	var coverImage:UIImage? = nil
	var url:URL? = nil
	init (timeStart: CMTime, timePlay: CMTime?, timeEnd: CMTime, musicAsset: AVAsset?,musicName:String, coverImage:UIImage?, url:URL?){
		super.init(timeStart: timeStart, timePlay: timePlay, timeEnd: timeEnd, aAsset: musicAsset)
		self.url = url
		self.coverImage = coverImage
		self.musicName = musicName
		self.type = AssetType.music
	}
}

class ImageTime:TimeAsset{
	
	init (timeStart: CMTime, timeEnd: CMTime, asset: UIImage, faces:[FaceFeatures])
	{
		super.init(timeStart: timeStart, timePlay: nil, timeEnd: timeEnd)
		self.type = AssetType.photo
		self.faces = faces
	}
}

public class   TimeLine{
	
	var myTimes:[TimeAsset]? = nil
	var	selectedAssets:[TLPHAsset]? = nil
	public var myBGM:MusicTime?
	//초기딜레이가 시작한시간~ // 영상이 시작한 시간 // 영상이 끝난시간 // 후기딜레이가 끝난시간 == 다음영상의 초기딜레이 시작
	
	init()
	{
		//TODO
	}
	
	public func makeTimeLine(selectedAssets:[TLPHAsset],complete:(()->()) ){
		
		for i in 0..<selectedAssets.count
		{
			let temp = selectedAssets[i]
			if temp.type == TLPHAsset.AssetType.video{
				myTimes?.append(VideoTime(timeStart: kCMTimeZero, timePlay: kCMTimeZero, timeEnd: kCMTimeZero, asset: temp.phAsset))
			}
			else{
				if temp.type == TLPHAsset.AssetType.photo{
					myTimes?.append(ImageTime(timeStart: kCMTimeZero, timeEnd: kCMTimeZero, asset: temp.fullResolutionImage!,faces:temp.faceFeatureFilter))
				}
				else if(temp.type == TLPHAsset.AssetType.livePhoto){
					print("라이브 포토는 어떡 하지")
				}
			}
		}
		//세마포 걸어야될수도잇음.
		complete()
	}
	
	public func removeAll(){
		myTimes?.removeAll()
		selectedAssets?.removeAll()
		myBGM = nil
	}
}
