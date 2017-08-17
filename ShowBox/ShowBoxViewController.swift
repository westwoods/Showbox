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


class ShowBoxViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{
	@IBOutlet var preViewCollectionView: UICollectionView!
	let myPhotoLib = TLPhotoLibrary()
	fileprivate var searches:[UIImage] = []
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
	
	@IBAction func savetoAlbum(_ sender: UIButton) {
		VideoWriter.saveToCameraRollAlbum()
	}
	var selectedAsset:TimeLine? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		VideoWriter.mergeVideo((selectedAsset)!,previewSize:self.ShowBox.bounds,complete:videoout)
	}
	func preViewGenerator(composition:AVComposition,mutableVideoCom:AVMutableVideoComposition){
		DispatchQueue.global().async {
			
			let imageGenerator = AVAssetImageGenerator(asset: composition)
			imageGenerator.videoComposition = mutableVideoCom
			var actualTime = kCMTimeZero
			var thumbnail : CGImage?
			print ("영상 길이는 ",Float((self.selectedAsset?.getTimes().last?.timePlayEnd.seconds)!),"초 입니다.")
			for i in 1..<(self.selectedAsset?.getTimes().count)!{
				autoreleasepool{//첫영상은 더미임으로 미리보기를 만들지 말자
				if let tempAsset = self.selectedAsset?.getTimes()[i]{
					if tempAsset.type == TimeAsset.AssetType.video{
						//	비디오 타입
						for timeScope in Int(tempAsset.timeStart.seconds)..<Int(tempAsset.timePlayEnd.seconds){
							do {
							thumbnail = try imageGenerator.copyCGImage(at: CMTimeMakeWithSeconds(Float64(timeScope), 1000), actualTime: &actualTime)
								self.searches.append(UIImage(cgImage: thumbnail!))
							}
							catch let error as NSError {
								print("video preview",error.localizedDescription)
							}
						}
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
			DispatchQueue.main.async {
				self.preViewCollectionView.reloadData()
			}
			self.selectedAsset?.removeAll()
		}
	}
	func videoout(composition:AVComposition,mutableVideoCom:AVMutableVideoComposition,layer:CALayer){
		DispatchQueue.main.async {
			let playerItem = AVPlayerItem(asset: composition)
			playerItem.videoComposition = mutableVideoCom//비디오 컴포지션 설정
			let synclayer:AVSynchronizedLayer = AVSynchronizedLayer.init(playerItem: playerItem)
			synclayer.addSublayer(layer )
			
			let player = AVPlayer(playerItem: playerItem)
			let playerLayer = AVPlayerLayer(player: player)
			playerLayer.frame = self.ShowBox.layer.bounds
//			playerLayer.contentsScale = 2.0
//			playerLayer.contentsGravity = AVLayerVideoGravityResize
			playerLayer.addSublayer(synclayer)
			self.ShowBox.layer.addSublayer(playerLayer)
			player.play()
			player.rate = 1.0
			self.preViewGenerator(composition:composition,mutableVideoCom: mutableVideoCom)
		}
	}
}
