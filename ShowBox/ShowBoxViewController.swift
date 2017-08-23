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
extension UICollectionView {
	
	var centerPoint : CGPoint {
		
		get {//
			print("위치",CGPoint(x: self.center.x + self.contentOffset.x, y:  self.contentOffset.y), self.contentOffset.y,  self.contentOffset.x )
			return CGPoint(x: self.center.x+self.contentOffset.x, y:  self.contentOffset.y) //center y값을빼니까 정상작동하네
		}
	}
	
	var centerCellIndexPath: IndexPath? {
		print("위치 센터 포인트",self.centerPoint)
		print("위치 이건 왜 닐이야",self.indexPathsForVisibleItems)
		print("위치 테스트", self.indexPathForItem(at: self.centerPoint))
		if let centerIndexPath = self.indexPathForItem(at: self.centerPoint) {
			return centerIndexPath
		}
		return nil
	}
}

class ShowBoxViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout{
	@IBOutlet var preViewCollectionView: UICollectionView!
	let myPhotoLib = TLPhotoLibrary()
	let player = AVPlayer()
	var pauseflag = false
	var searches:[UIImage] = []
	var timeObserverToken: Any?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Make sure we don't have a strong reference cycle by only capturing self as weak.
		
	}
	
	var currentTime: CMTime {
		get {
			return player.currentTime()
		}
		set {
			let newTime = newValue
			player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)// before와 after가 0이면 정확한 시간 decoding이 더 필요함. 여분시간을 줄경우 좀더 빨리 찾아지나봄!
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
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
		if !decelerate{//즉시 멈춘경우
		updatetimeLable()
		}
	}
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
		updatetimeLable()
	}
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return searches.count
	}
	
	func collectionView(_ collectionView: UICollectionView,
	                    numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	//시간에 따라 셀크기 맞추는 함수
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var timeduration = 9.0
		if indexPath.section>=1 && indexPath.section < (selectedAsset?.getTimes().count)!{
			timeduration = CMTimeSubtract((self.selectedAsset?.getTimes()[indexPath.section].timePlayEnd)!,(selectedAsset?.getTimes()[indexPath.section].timeStart)! ).seconds
			print ("타이머",timeduration)
		}
		return CGSize(width: 35*timeduration, height: 76);
	}
	
	func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellIdentifier = "PreViewCollectionViewCell"
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PreViewCollectionViewCell  else {
			fatalError("The dequeued cell is not an instance of MusicTableViewCell.")
		}
		//print(indexPath.section)
		cell.preViewImage.image = searches[indexPath.section]
		if (indexPath.section>=1 && indexPath.section < (selectedAsset?.getTimes().count)!){
			cell.layer.borderWidth = 1.0
			let myColor = UIColor(red: 255/255, green: 44/255, blue: 88/255, alpha: 0.5)
			cell.layer.borderColor = myColor.cgColor
		}
		else{
			cell.layer.borderWidth = 1.0
			let myColor = UIColor(red: 22/255, green: 44/255, blue: 255/255, alpha: 0.22)
			cell.layer.borderColor = myColor.cgColor
		}
		return cell
	}
	func updatetimeLable()
	{
		DispatchQueue.main.async {
		let time:Double = (Double(self.preViewCollectionView.centerPoint.x)-35*8.0)/35.0
		let mins:Int = Int(time) / 60 //In this case it would be 1
		let secs:Int = Int(time - Double(mins * 60)) //And this would be 10
		let milisec:Int = Int((time - Double(mins * 60) - Double(secs))*100)
		self.timeLabel.text = String.init(format: "%02d:", mins)+String.init(format: "%02d", secs)+String.init(format: ".%02d", milisec)
		}
	}
	
	@IBOutlet var ShowBox: UIView!
	@IBOutlet var pauseButton: UIButton!
	@IBAction func pauseButtonTapped(_ sender: UIButton) {
		currentTime = CMTime(seconds: (Double(preViewCollectionView.centerPoint.x)-35*8.0)/35.0, preferredTimescale: 100)//TODO
		player.play()
		pauseflag = false
		pauseButton.isHidden = true
	}
	@IBAction func savetoAlbum(_ sender: UIButton) {
		if VideoWriter.session?.status == AVAssetExportSessionStatus.completed{
			let alert = UIAlertController(title: "저장", message: "저장되었습니다.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			//		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {    (action:UIAlertAction!) in
			//			print("you have pressed the Cancel button")
			//		}))
			self.present(alert, animated: true, completion: nil)
			VideoWriter.saveToCameraRollAlbum()
		}
		else{
			let alert = UIAlertController(title: "에러", message: "영상이 아직 완성되지 않았어요 ㅠ.ㅠ", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			//		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {    (action:UIAlertAction!) in
			//			print("you have pressed the Cancel button")
			//		}))
			self.present(alert, animated: true, completion: nil)
		}
	}
	var exportprogress :KDCircularProgress?
	var selectedAsset:TimeLine? = nil //세그로 세팅됨
	
	override func viewDidLoad() {
		super.viewDidLoad()
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
		DispatchQueue.global().async {
			VideoWriter.mergeVideo((self.selectedAsset)!,previewSize:self.ShowBox.bounds, complete:self.videoout)
			
		}
	}
	@IBOutlet var saveButton: UIButton!
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		VideoWriter.stop()
		if let timeObserverToken = timeObserverToken {
			player.removeTimeObserver(timeObserverToken)
			self.timeObserverToken = nil
		}
		player.pause()
		self.selectedAsset?.removeAll()
	}
	
	@IBOutlet var timeLabel: UILabel!
	
	func preViewGenerator(composition:AVComposition,mutableVideoCom:AVMutableVideoComposition){
		DispatchQueue.global().async {
			
			let imageGenerator = AVAssetImageGenerator(asset: composition)
			imageGenerator.videoComposition = mutableVideoCom
			var actualTime = kCMTimeZero
			var thumbnail : CGImage?
			print ("영상 길이는 ",Float((self.selectedAsset?.getTimes().last?.timePlayEnd.seconds)!),"초 입니다.")
			
			
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
						else	if tempAsset.type == TimeAsset.AssetType.photo ||  tempAsset.type == TimeAsset.AssetType.map{
							//포토 타입
							self.searches.append(tempAsset.iAsset!)
						}
					}
				}
			}
			self.searches.append(UIImage())
			
			DispatchQueue.main.async {
				self.preViewCollectionView.reloadData()
				let interval = CMTimeMake(1, 30)
				self.timeObserverToken = self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] time in
					//	print ("타이머",VideoWriter.session?.progress ?? "")
					self.exportprogress?.angle = Double((VideoWriter.session?.progress ?? 0 )*360)
					self.exportprogress?.isHidden = false
					if !self.pauseflag{
						
						self.preViewCollectionView.setContentOffset(CGPoint.init(x: (self.player.currentTime().seconds-1)*35+9*35-187.5, y: 0.0), animated: false)
						//print(time)
						let time:Double = self.player.currentTime().seconds //This can be any value
						let mins:Int = Int(time) / 60 //In this case it would be 1
						let secs:Int = Int(time - Double(mins * 60)) //And this would be 10
						let milisec:Int = Int((time - Double(mins * 60) - Double(secs))*100)
						self.timeLabel.text = String.init(format: "%02d:", mins)+String.init(format: "%02d", secs)+String.init(format: ".%02d", milisec)
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
			self.pauseButton.isHidden = true
			self.player.rate = 1.0
			self.preViewGenerator(composition:composition,mutableVideoCom: mutableVideoCom)
		}
	}
	
}

