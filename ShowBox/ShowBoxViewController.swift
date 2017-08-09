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


class ShowBoxViewController: UIViewController {
	
	@IBOutlet var ShowBox: UIView!
	
	var selectedAsset:TimeLine? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
			VideoWriter.mergeVideo((selectedAsset)!,complete:videoout)
	}
	
	func videoout(composition:AVComposition,mutableVideoCom:AVMutableVideoComposition,layer:CALayer){
		DispatchQueue.main.async {
		self.selectedAsset?.removeAll()
        let playerItem = AVPlayerItem(asset: composition)
        playerItem.videoComposition = mutableVideoCom//비디오 컴포지션 설정
		let synclayer:AVSynchronizedLayer = AVSynchronizedLayer.init(playerItem: playerItem)
		synclayer.frame = self.ShowBox.layer.frame
		synclayer.addSublayer(layer )
		
		let player = AVPlayer(playerItem: playerItem)
			print (composition.duration)
			let playerLayer = AVPlayerLayer(player: player)
			playerLayer.frame = self.ShowBox.bounds
			playerLayer.addSublayer(synclayer)
			self.ShowBox.layer.addSublayer(playerLayer)
			player.play()
		}
	}
}
