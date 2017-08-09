//
//  ShowBoxViewController.swift
//  ShowBox
//
//  Created by snow on 2017. 8. 8..
//  Copyright © 2017년 snow. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation


class ShowBoxViewController: UIViewController {
	
	
	@IBOutlet var ShowBox: UIView!
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		VideoWriter.mycompletefunc = videoout
	}
	func videoout(composition:AVMutableComposition){
		DispatchQueue.main.async {
			let player = AVPlayer(playerItem: AVPlayerItem(asset: composition))
			print (composition.duration)
			let playerLayer = AVPlayerLayer(player: player)
			playerLayer.frame = self.ShowBox.bounds
			self.ShowBox.layer.addSublayer(playerLayer)
			player.play()
		}
	}
}
