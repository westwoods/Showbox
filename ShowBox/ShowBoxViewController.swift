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
	
	func videoout(composition:AVMutableComposition,layer:AVMutableVideoComposition){
		
				selectedAsset?.removeAll()
        let playerItem = AVPlayerItem(asset: composition)
        playerItem.videoComposition = layer //비디오 컴포지션 설정
		let player = AVPlayer(playerItem: playerItem)
			print (composition.duration)
			let playerLayer = AVPlayerLayer(player: player)
			playerLayer.frame = self.ShowBox.bounds
			self.ShowBox.layer.addSublayer(playerLayer)
			player.play()
	}
}
