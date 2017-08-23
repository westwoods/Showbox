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
import KDCircularProgress
public class TimeAsset{
	public enum AssetType {
		case photo,video,livePhoto,music,map,unknown
	}
	public enum SelectedHighLight {
		case selected, highLighted, none
	}
	public enum FaceFeatures {
		case none , eye, smile, many
	}
	var iAsset:UIImage?
	let aAsset:AVAudioMix?
	let musicAsset:AVAsset?
	var vAsset:AVAsset?
	var phAsset:PHAsset?
	var type: AssetType = .unknown
	var timeStart:CMTime
	var timePlayEnd:CMTime
	var timeDelayEnd:CMTime
	var locationGroup:Int?
	public var selectedOrder: Int = 0
	public var selectedHighLight: SelectedHighLight = .none  //0 nomal 1 selected 2 highlighted
	public var faces:[FaceFeatures] = []
	
	init (timeStart : CMTime,  timePlayEnd : CMTime, timeDelayEnd : CMTime,	phAsset:PHAsset? = nil	,iAsset :UIImage? = nil, vAsset:AVAsset? = nil, musicAsset:AVAsset? = nil, aAsset:AVAudioMix? = nil, type:AssetType = AssetType.unknown){
		self.timeStart = timeStart
		self.timePlayEnd = timePlayEnd
		self.timeDelayEnd = timeDelayEnd
		self.iAsset = iAsset
		self.aAsset = aAsset
		self.vAsset = vAsset
		self.musicAsset = musicAsset
		self.phAsset = phAsset
	}
}


class VideoTime:TimeAsset{
	init (timeStart: CMTime, timePlayEnd: CMTime, timeDelayEnd: CMTime, vAsset: AVAsset?){
		super.init(timeStart: timeStart, timePlayEnd: timePlayEnd, timeDelayEnd: timeDelayEnd, vAsset: vAsset)
		
		self.type = AssetType.video
	}
}

public class MusicTime:TimeAsset{
	var musicName: String = ""
	var coverImage:UIImage? = nil
	var url:URL? = nil
	init (timeStart: CMTime, timePlay: CMTime, timeEnd: CMTime, musicAsset: AVAsset?,musicName:String, coverImage:UIImage?, url:URL?){
		super.init(timeStart: timeStart, timePlayEnd: timePlay, timeDelayEnd: timeEnd, musicAsset: musicAsset)
		self.url = url
		self.coverImage = coverImage
		self.musicName = musicName
		self.type = AssetType.music
	}
}

class ImageTime:TimeAsset{
	init (timeStart: CMTime, timePlayEnd: CMTime,phAsset:PHAsset?, iAsset: UIImage?, faces:[FaceFeatures], locationGroup:Int?)
	{
		super.init(timeStart: timeStart, timePlayEnd: timePlayEnd, timeDelayEnd: kCMTimeInvalid,phAsset: phAsset)
		self.type = AssetType.photo
		self.iAsset = iAsset
		self.faces = faces
		self.locationGroup = locationGroup
	}
}


public class   TimeLine{
	public func getTimes()->[TimeAsset]{
		return myTimes
	}
	var progress:KDCircularProgress? = nil
	
	lazy var imageManager = {
		return PHCachingImageManager()
	}()
	var myTimes:[TimeAsset] = []
	var	selectedAssets:[TLPHAsset] = []
	var complete:(()->())? = nil
	
	var title1:String = ""
	var title2:String = ""

	public var timecut:CMTime = kCMTimeInvalid
	public var myBGM:MusicTime?
	
	public var defaultBGM:MusicTime?
	var semaphore:DispatchSemaphore = DispatchSemaphore(value: 0)
	//초기딜레이가 시작한시간~ // 영상이 시작한 시간 // 영상이 끝난시간 // 후기딜레이가 끝난시간 == 다음영상의 초기딜레이 시작
	
	
	init(sprogress:KDCircularProgress)
	{
		
		let thisBundle = Bundle(for: type(of: self))
		let url = thisBundle.url(forResource: "Splashing_Around", withExtension: "mp3")
		let splashign_Around = AVAsset(url: url!)
		let music = MusicTime.init(timeStart: kCMTimeZero, timePlay: CMTimeAdd(kCMTimeZero, CMTime(seconds: 154.749, preferredTimescale: 44100)), timeEnd: CMTimeAdd(kCMTimeZero, CMTime(seconds: 154.749, preferredTimescale: 44100)), musicAsset: splashign_Around, musicName: "Aplashing_Around", coverImage: #imageLiteral(resourceName: "Atlanta.jpeg"),url: url)
		myBGM = music
		defaultBGM = music
		progress = sprogress
	}
	
	public func makeTimeLine(selectedAssets:[TLPHAsset],complete:@escaping (()->()),title1:String,title2:String ){
		self.title1 = title1
		self.title2 = title2
		let nextDelayTime:TimeInterval = 2
		let mapDelayTime:TimeInterval = 4
		var startTime:CMTime = kCMTimeZero
		let nextDelay:CMTime = CMTimeMakeWithSeconds(nextDelayTime, 100)
		let mapDelay:CMTime = CMTimeMakeWithSeconds(mapDelayTime, 100)
		semaphore = DispatchSemaphore(value: 0)
		self.selectedAssets = selectedAssets
		self.complete = complete
		let thisBundle = Bundle(for: type(of: self))
		let introAsset = AVAsset(url:  thisBundle.url(forResource: "intro", withExtension: "MOV")!)
		let intro = VideoTime(timeStart: startTime, timePlayEnd:introAsset.duration, timeDelayEnd: introAsset.duration, vAsset:introAsset)
		self.myTimes.append(	intro)
		var latestVideo:VideoTime = intro
		startTime = CMTimeAdd(startTime, introAsset.duration)
		var musicpoint:Int = 0
		let myPhLib = TLPhotoLibrary()
		var nowGroup = -1
		var gap = kCMTimeZero
		self.progress?.angle = 0
		for i in 0..<selectedAssets.count
		{ autoreleasepool{
			DispatchQueue.main.async {
				self.progress?.angle += (360/Double(selectedAssets.count))
				if((self.progress?.angle ?? 0)>359.0){
					self.progress?.isHidden = true
					
				}
				else{
					self.progress?.isHidden = false
				}
			}
			let temp = selectedAssets[i]
			//음악과 맞추는것,,, 어떻게 할까
			/***************************************************************************************************************/
			/*
			1. 동영상은 전체 구간을 재생
			
			2. 전환 효과별 dafualt타임보다 2초이상 남을시 dafualt 타임을 적용하고(현 2초) 다음이미지 호출
			
			3. 남은 시간이 2초보다 적을시 이번 전환 효과를 전환 효과 시간을 늘이거나 전환효과를 더 긴것으로 바꿈
			
			4. 마지막 이미지와 동영상은 배경음악 포인트까지 진행한다
			*/
			while (musicpoint<MusicTimeTable.splashing_Around.count-1 && MusicTimeTable.splashing_Around[musicpoint] < CMTimeAdd(startTime, nextDelay)){
				musicpoint+=1
			}
			let musicgap = CMTimeSubtract(MusicTimeTable.splashing_Around[musicpoint],CMTimeAdd(startTime, nextDelay)) //뮤직 포인트와 현재 사진 끝나는 시간과의 갭
			
			if( musicgap <  nextDelay ||  i == selectedAssets.count-1){
				gap = musicgap
			}
			else{
				gap = kCMTimeZero
			}
			/*************************************************************************************************************/
			
			if temp.type == TLPHAsset.AssetType.video{
				let options = PHVideoRequestOptions()
				imageManager.requestAVAsset(forVideo: temp.phAsset!, options: options, resultHandler: { (AVAsset, AVAudioMix, info) in
					latestVideo.timeDelayEnd = startTime // 이전 영상이 다음 영상의 시작 시간까지 담당.
					let nextVideo = VideoTime(timeStart: startTime, timePlayEnd:CMTimeAdd(startTime, (AVAsset?.duration)!), timeDelayEnd: kCMTimeInvalid, vAsset: AVAsset)
					self.myTimes.append(	nextVideo )
					latestVideo = nextVideo
					startTime = CMTimeAdd(startTime, (AVAsset?.duration)!)
					
					
					self.semaphore.signal()
				})
				semaphore.wait()
			}
			else{
				
				
				if temp.type == TLPHAsset.AssetType.photo{
					if let mapimage = LocalImageDIc[temp.clusterGroup]  {
						if (temp.clusterGroup != nowGroup){ //최근 한번만 추가.
							nowGroup = temp.clusterGroup
							//	지도 이미지추가
							for j in i..<selectedAssets.count
							{
								if (selectedAssets[j].type == TLPHAsset.AssetType.photo)
								{
									if  selectedAssets[j].clusterGroup != -1  {
										if (selectedAssets[j].clusterGroup != nowGroup){
											print("여기야 여기", nowGroup,selectedAssets[j].clusterGroup ,"i",i,"j:",j )
											break
										}
									}
								}
							}
							let mapimage = ImageTime(timeStart: startTime, timePlayEnd: CMTimeAdd(startTime, CMTimeAdd(mapDelay, gap)), phAsset: nil, iAsset:mapimage ,faces:temp.faceFeatureFilter, locationGroup:temp.clusterGroup)
							mapimage.type = TimeAsset.AssetType.map
							myTimes.append(mapimage)
							startTime = CMTimeAdd(startTime, CMTimeAdd(mapDelay, gap))
							latestVideo.timeDelayEnd = startTime
						}
					}
					myPhLib.getThumbnailAsset(asset: temp.phAsset!, size: CGSize(width:(temp.phAsset?.pixelWidth)!/4, height:(temp.phAsset?.pixelHeight)!/4)){[unowned self]uiimage in
						self.myTimes.append(ImageTime(timeStart: startTime, timePlayEnd: CMTimeAdd(startTime, CMTimeAdd(nextDelay, gap)), phAsset: temp.phAsset, iAsset: uiimage,faces:temp.faceFeatureFilter, locationGroup:temp.clusterGroup))
						debugPrint("TDphoto start", startTime,"\n")
						startTime = CMTimeAdd(startTime, CMTimeAdd(nextDelay, gap))
						latestVideo.timeDelayEnd = startTime
						debugPrint("TDphoto end",startTime,"\n")
					}
				}
				else if(temp.type == TLPHAsset.AssetType.livePhoto){
					print("라이브 포토는 이미지와 영상이 합쳐진 형태임.")
				}
				
			}
			}
		}
		//
		//		debugPrint("TD Lvideo start", latestVideo.timeStart,"\n")
		//		debugPrint("TD Lvideo dend", latestVideo.timeDelayEnd,"\n")
		if myTimes.last?.type == TimeAsset.AssetType.video{
			latestVideo.timeDelayEnd = CMTimeAdd(latestVideo.timePlayEnd  , gap)
			latestVideo.timePlayEnd = latestVideo.timeDelayEnd
			//영상으로 끝이 날때는!
		}
		
		self.timecut = latestVideo.timeDelayEnd
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
