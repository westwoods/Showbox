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
public class TimeAssets{
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
	let musicAsset:AVAsset?
	let type: AssetType = .unknown
	var timeStart:CMTime
	var timePlay:CMTime?
	var timeEnd:CMTime
	
	public var selectedOrder: Int = 0
	public var selectedHighLight: SelectedHighLight = .none  //0 nomal 1 selected 2 highlighted
	public var faces:[FaceFeatures] = []
	
	init (timeStart : CMTime,  timePlay : CMTime?, timeEnd : CMTime,		asset :PHAsset? = nil, musicAsset:AVAsset? = nil){
		self.timeStart = timeStart
		self.timePlay = timePlay
		self.timeEnd = timeEnd
		self.asset = asset
		self.musicAsset = musicAsset
	}
}
class VideoTime:TimeAssets{
	init (timeStart: CMTime, timePlay: CMTime?, timeEnd: CMTime, asset: PHAsset?){
		super.init(timeStart: timeStart, timePlay: timePlay, timeEnd: timeEnd, asset: asset)
	}
}
public class MusicTime:TimeAssets{
	var musicName: String = ""
	var coverImage:UIImage? = nil
	var url:URL? = nil
	init (timeStart: CMTime, timePlay: CMTime?, timeEnd: CMTime, musicAsset: AVAsset?,musicName:String, coverImage:UIImage?, url:URL?){
		super.init(timeStart: timeStart, timePlay: timePlay, timeEnd: timeEnd, musicAsset: musicAsset)
		self.url = url
		self.coverImage = coverImage
		self.musicName = musicName
	}
}
class ImageTime:TimeAssets{
	init (timeStart: CMTime, timeEnd: CMTime, asset: PHAsset)
	{
		super.init(timeStart: timeStart, timePlay: nil, timeEnd: timeEnd, asset: asset)
	}
}

//imageManager.requestAVAsset(forVideo: self.selectedAssets[i].phAsset!, options: options, resultHandler: { (AVAsset, AVAudioMix, info) in
//	self.mySelectedAsset.myTimes?.(TimeAssets(timeStart: <#T##CMTime#>, timePlay: <#T##CMTime?#>, timeEnd: <#T##CMTime#>, asset: <#T##PHAsset?#>, musicAsset: <#T##AVAsset?#>) //비디오타입 PHAsset -> AVAsset 변환작업
//	if(self.myVideoAsset.count == self.videoCount )
//	{
//	//  VideoWriter.exportAsset(asset: self.myVideoAsset[0])
//
//	}
//	})

public class   TimeLine{
	
	var myTimes:[TimeAssets]? = nil
	var	selectedAssets:[TLPHAsset]? = nil
	public var myBGM:MusicTime?
 //초기딜레이가 시작한시간~ // 영상이 시작한 시간 // 영상이 끝난시간 // 후기딜레이가 끝난시간 == 다음영상의 초기딜레이 시작
	init()
	{//TODO
		
	}
	public func makeTimeLine(selectedAssets:[TLPHAsset],complete:(()->()) ){
	
		print("여기 호출됨")
		complete()
	}
	public func removeAll(){
		//TODO
		
	}
}
