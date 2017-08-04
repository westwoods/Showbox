//
//  TimeLineStruct.swift
//  ShowBox
//
//  Created by snow on 2017. 8. 4..
//  Copyright © 2017년 snow. All rights reserved.
//

import AVFoundation
import Foundation
class VideoTime{
	let timeStart:CMTime
	let timePlay:CMTime
	let timeEnd:CMTime
	init (){
		timeStart = CMTime()
		timePlay = CMTime()
		timeEnd = CMTime()
	}
}

class ImageTime{
	
	let timeStart:CMTime
	let timeEnd:CMTime
	init ()
	{
		
		timeStart = CMTime()
		timeEnd = CMTime()
	}
}

class   TimeLine{
	
	var VideoTimes:[VideoTime]
 //초기딜레이가 시작한시간~ // 영상이 시작한 시간 // 영상이 끝난시간 // 후기딜레이가 끝난시간 == 다음영상의 초기딜레이 시작
	var ImageTimes:[ImageTime]
	
	init()
	{
			VideoTimes = [VideoTime()]
			ImageTimes = [ImageTime()]
	}
}
