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
	
	func videoout(composition:AVComposition,mutableVideoCom:AVMutableVideoComposition,layer:CALayer){
		DispatchQueue.main.async {
			let playerItem = AVPlayerItem(asset: composition)
			playerItem.videoComposition = mutableVideoCom//비디오 컴포지션 설정
			let synclayer:AVSynchronizedLayer = AVSynchronizedLayer.init(playerItem: playerItem)
			synclayer.addSublayer(layer )
			
			let player = AVPlayer(playerItem: playerItem)
			print (composition.duration)
			let playerLayer = AVPlayerLayer(player: player)
			playerLayer.frame = self.ShowBox.layer.bounds
			playerLayer.contentsScale = 2.0
			playerLayer.contentsGravity = AVLayerVideoGravityResize
			print(playerLayer.frame)
			print(self.ShowBox.bounds)
			print(synclayer.frame)
			print(self.ShowBox.layer.frame)
			playerLayer.addSublayer(synclayer)
			self.ShowBox.layer.addSublayer(playerLayer)
			player.play()
			DispatchQueue.global().async {
				
			let imageGenerator = AVAssetImageGenerator(asset: composition)
				imageGenerator.videoComposition = mutableVideoCom
			var actualTime = kCMTimeZero
			var thumbnail : CGImage?
			print ("마지막 시간",Int((self.selectedAsset?.getTimes().last?.timePlayEnd.seconds)!))
			for i in 0..<(self.selectedAsset?.getTimes().count)!{
				if let tempAsset = self.selectedAsset?.getTimes()[i]{
					if tempAsset.type == TimeAsset.AssetType.video{
						//	비디오 타입
						for timeScope in Int(tempAsset.timeStart.seconds)..<Int(tempAsset.timePlayEnd.seconds){
							do {
								thumbnail = try imageGenerator.copyCGImage(at: CMTimeMakeWithSeconds(Float64(timeScope)+0.5, 1000), actualTime: &actualTime)
								self.searches.append(UIImage(cgImage: thumbnail!))
							}
							catch let error as NSError {
								print(error.localizedDescription)
							}
						}
					}
					else {
						//포토 타입
						self.searches.append(tempAsset.passet!)
					}
				}
			}
				DispatchQueue.main.async {
				self.preViewCollectionView.reloadData()
				}
				self.selectedAsset?.removeAll()
			}
			
		}
	}
}
