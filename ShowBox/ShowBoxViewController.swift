//
//  ShowBoxViewController.swift
//  ShowBox
//
//  Created by snow on 2017. 8. 8..
//  Copyright © 2017년 snow. All rights reserved.
//
import AVKit
import AVFoundation
import UIKit
import KDCircularProgress


class ShowBoxViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate{
	@IBOutlet var preViewCollectionView: UICollectionView!
	let myPhotoLib = TLPhotoLibrary()
	let player = AVPlayer()
	var pauseflag = false
	fileprivate var searches:[UIImage] = []
	private var timeObserverToken: Any?
	
	var currentTime: Double {
		get {
			return CMTimeGetSeconds(player.currentTime())
		}
		set {
			let newTime = CMTimeMakeWithSeconds(newValue, 1)
			player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
		}
	}
	
	var duration: Double {
		guard let currentItem = player.currentItem else { return 0.0 }
		
		return CMTimeGetSeconds(currentItem.duration)
	}
	
	var rate: Float {
		get {
			return player.rate
		}
		
		set {
			player.rate = newValue
		}
	}
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
		self.pauseflag = true
		pauseButton.isHidden = false
		player.pause()
		
	}
	
	//1
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return searches.count
	}
	
	//2
	func collectionView(_ collectionView: UICollectionView,
	                    numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	//3
 func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
	let cellIdentifier = "PreViewCollectionViewCell"
	
	guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PreViewCollectionViewCell  else {
		fatalError("The dequeued cell is not an instance of MusicTableViewCell.")
	}
	//print(indexPath.section)
	cell.preViewImage.image = searches[indexPath.section]
	return cell
	}
	
	@IBOutlet var ShowBox: UIView!
	@IBOutlet var pauseButton: UIButton!
	@IBAction func pauseButtonTapped(_ sender: UIButton) {
		player.play()
		pauseflag = false
		pauseButton.isHidden = true
	}
	@IBAction func savetoAlbum(_ sender: UIButton) {
		VideoWriter.saveToCameraRollAlbum()
	}
	var exportprogress :KDCircularProgress?
	var selectedAsset:TimeLine? = nil //세그로 세팅됨
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Make sure we don't have a strong reference cycle by only capturing self as weak.
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
		progress.startAngle = -90
		progress.progressThickness = 0.2
		progress.trackThickness = 0.3
		progress.clockwise = true
		progress.gradientRotateSpeed = 2
		progress.roundedCorners = false
		progress.glowMode = .constant
		progress.glowAmount = 0.2
		progress.set(colors: UIColor.lightGray, UIColor.darkGray, UIColor.black, UIColor.darkGray)
		progress.trackColor = UIColor.white
		progress.center = CGPoint(x: view.center.x, y: view.center.y - 35)
		progress.isHidden = true
		
		exportprogress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
		if let exportprogress = exportprogress{
			exportprogress.startAngle = -90
			exportprogress.progressThickness = 0.2
			exportprogress.trackThickness = 0.2
			exportprogress.clockwise = true
			exportprogress.gradientRotateSpeed = 2
			exportprogress.roundedCorners = false
			exportprogress.glowMode = .constant
			exportprogress.glowAmount = 0.2
			exportprogress.set(colors: UIColor.lightGray, UIColor.darkGray, UIColor.black, UIColor.darkGray)
			exportprogress.trackColor = UIColor.white
			exportprogress.center = CGPoint(x: saveButton.center.x, y: saveButton.center.y )
			exportprogress.isHidden = false
			view.addSubview(exportprogress)
		}
		view.addSubview(progress)
		VideoWriter.progress = progress
		DispatchQueue.global().async {
			VideoWriter.mergeVideo((self.selectedAsset)!,previewSize:self.ShowBox.bounds, complete:self.videoout)
		}
		startTimer()
	}
	@IBOutlet var saveButton: UIButton!
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		VideoWriter.stop()
		stopTimerTest()
		if let timeObserverToken = timeObserverToken {
			player.removeTimeObserver(timeObserverToken)
			self.timeObserverToken = nil
		}
		player.pause()
		self.selectedAsset?.removeAll()
	}
	
	var timerTest : Timer?
	func startTimer () {
		
  if timerTest == nil {
	timerTest =  Timer.scheduledTimer(
		timeInterval: TimeInterval(2.0),
		target      : self,
		selector    : #selector(self.timerActionTest),
		userInfo    : nil,
		repeats     : true)
		}
	}
	func stopTimerTest() {
		if timerTest != nil {
			timerTest!.invalidate()
			timerTest = nil
		}
	}
	
	func timerActionTest(){
		DispatchQueue.main.async {
			print ("valval타이머",VideoWriter.session?.progress ?? "없어댜")
			self.exportprogress?.angle = Double((VideoWriter.session?.progress ?? 0 )*360)
			self.exportprogress?.isHidden = false
		}
	}
	func preViewGenerator(composition:AVComposition,mutableVideoCom:AVMutableVideoComposition){
		DispatchQueue.global().async {
			
			let imageGenerator = AVAssetImageGenerator(asset: composition)
			imageGenerator.videoComposition = mutableVideoCom
			var actualTime = kCMTimeZero
			var thumbnail : CGImage?
			print ("영상 길이는 ",Float((self.selectedAsset?.getTimes().last?.timePlayEnd.seconds)!),"초 입니다.")
			
			self.searches.append(UIImage())
			
			self.searches.append(UIImage())
			
			self.searches.append(UIImage())
			
			for i in 1..<(self.selectedAsset?.getTimes().count)!{
				autoreleasepool{//첫영상은 더미임으로 미리보기를 만들지 말자
					if let tempAsset = self.selectedAsset?.getTimes()[i]{
						if tempAsset.type == TimeAsset.AssetType.video{
							//	비디오 타입
							//for timeScope in Int(tempAsset.timeStart.seconds)..<Int(tempAsset.timePlayEnd.seconds){
							let timeScope = (tempAsset.timeStart.seconds)
							do {
								thumbnail = try imageGenerator.copyCGImage(at: CMTimeMakeWithSeconds(Float64(timeScope+0.5), 1000), actualTime: &actualTime)
								self.searches.append(UIImage(cgImage: thumbnail!))
							}
							catch let error as NSError {
								print("video preview",error.localizedDescription)
							}
							//}
						}
						else {
							//포토 타입
							()
							if let phAsset = tempAsset.phAsset{
								self.myPhotoLib.getThumbnailAsset(asset:phAsset, completionBlock: { (uiimage) in
									self.searches.append(uiimage)
								})
							}
							else{
								self.searches.append(tempAsset.passet!)
							}
						}
					}
				}
			}
			self.searches.append(UIImage())
			
			self.searches.append(UIImage())
			
			self.searches.append(UIImage())
			
			DispatchQueue.main.async {
				self.preViewCollectionView.reloadData()
				let interval = CMTimeMake(1, 2)
				self.timeObserverToken = self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] time in
					if !self.pauseflag{
						let times = self.selectedAsset?.getTimes()
						for i in 1..<(times?.count ?? 0) //0번 더미영상  1번부터 시작
						{
							if (times?[i].timeStart)! < time && ((times?[i].timePlayEnd)! > time){
								self.preViewCollectionView.scrollToItem(at: IndexPath.init(row: 0, section: i+2), at: UICollectionViewScrollPosition.centeredHorizontally , animated: true)
								break
							}
						}
						print(time)
					}
				}
			}
		}
	}
	
	
	func videoout(composition:AVComposition,mutableVideoCom:AVMutableVideoComposition,layer:CALayer){
		DispatchQueue.main.async {
			let playerItem = AVPlayerItem(asset: composition)
			playerItem.videoComposition = mutableVideoCom//비디오 컴포지션 설정
			let synclayer:AVSynchronizedLayer = AVSynchronizedLayer.init(playerItem: playerItem)
			synclayer.addSublayer(layer )
			self.player.replaceCurrentItem(with: playerItem)
			let playerLayer = AVPlayerLayer(player: self.player)
			playerLayer.frame = self.ShowBox.layer.bounds
			//			playerLayer.contentsScale = 2.0
			//			playerLayer.contentsGravity = AVLayerVideoGravityResize
			playerLayer.addSublayer(synclayer)
			self.ShowBox.layer.addSublayer(playerLayer)
			self.player.play()
			self.player.rate = 1.0
			self.preViewGenerator(composition:composition,mutableVideoCom: mutableVideoCom)
		}
	}
	
}

