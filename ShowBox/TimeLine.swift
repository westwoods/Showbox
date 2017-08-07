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
fileprivate class TimeAssets{
	public enum AssetType {
		case photo,video,livePhoto,unknown
	}
	public enum SelectedHighLight {
		case selected, highLighted, none
	}
	public enum FaceFeatures {
		case none , eye, smile, many
	}
	let asset:PHAsset
	let type: AssetType = .unknown
	var timeStart:CMTime
	var timePlay:CMTime?
	var timeEnd:CMTime
	
	public var selectedOrder: Int = 0
	public var selectedHighLight: SelectedHighLight = .none  //0 nomal 1 selected 2 highlighted
	public var faces:[FaceFeatures] = []
	
	init (timeStart : CMTime,  timePlay : CMTime?, timeEnd : CMTime,		asset :PHAsset){
		self.timeStart = timeStart
		self.timePlay = timePlay
		self.timeEnd = timeEnd
		self.asset = asset
	}
}
fileprivate class VideoTime:TimeAssets{
	override init (timeStart: CMTime, timePlay: CMTime?, timeEnd: CMTime, asset: PHAsset){
		super.init(timeStart: timeStart, timePlay: timePlay, timeEnd: timeEnd, asset: asset)
	}
}

fileprivate class ImageTime:TimeAssets{
	init (timeStart: CMTime, timeEnd: CMTime, asset: PHAsset)
	{
		super.init(timeStart: timeStart, timePlay: nil, timeEnd: timeEnd, asset: asset)
	}
}
fileprivate class   TimeLine{
	
	var myTimes:[TimeAssets]? = nil
 //초기딜레이가 시작한시간~ // 영상이 시작한 시간 // 영상이 끝난시간 // 후기딜레이가 끝난시간 == 다음영상의 초기딜레이 시작

	
	init()
	{
		
	}
}
