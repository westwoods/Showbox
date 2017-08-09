//
//  AudioViewController.swift
//  ShowBox
//
//  Created by snow on 2017. 8. 7..
//  Copyright © 2017년 snow. All rights reserved.
//

import UIKit
import AVFoundation
import FDWaveformView
public class AudioViewController: UITableViewController,FDWaveformViewDelegate {
	var player = AVPlayer()
	public var selectedMusic:MusicTime? = nil
	
	@IBAction func exit(_ sender: UIButton) {
		
	}
	@IBAction func musicSelected(_ sender: UIButton) {
		
	}
	var musics = [MusicTime]()
	private func loadSampleMusics() {
		
		let thisBundle = Bundle(for: type(of: self))
		
		var url = thisBundle.url(forResource: "Splashing_Around", withExtension: "mp3")
		var splashign_Around = AVAsset(url: url!)
		var music = MusicTime.init(timeStart: kCMTimeZero, timePlay: CMTimeAdd(kCMTimeZero, CMTime(seconds: 154.749, preferredTimescale: 44100)), timeEnd: CMTimeAdd(kCMTimeZero, CMTime(seconds: 154.749, preferredTimescale: 44100)), musicAsset: splashign_Around, musicName: "Aplashing_Around", coverImage: #imageLiteral(resourceName: "Atlanta.jpeg"),url: url)
		musics += [music]
		url = thisBundle.url(forResource: "Atlanta", withExtension: "mp3")
		splashign_Around = AVAsset(url: url!)
		music = MusicTime.init(timeStart: kCMTimeZero, timePlay: CMTimeAdd(kCMTimeZero, CMTime(seconds: 30.0, preferredTimescale: 100000)), timeEnd: CMTimeAdd(kCMTimeZero, CMTime(seconds: 30.0, preferredTimescale: 100000)), musicAsset: splashign_Around, musicName: "Atlanta", coverImage: #imageLiteral(resourceName: "Splashing_Around.jpg"),url: url)
		musics += [music]
		
		url = thisBundle.url(forResource: "Humidity", withExtension: "mp3")
		splashign_Around = AVAsset(url: url!)
		music = MusicTime.init(timeStart: kCMTimeZero, timePlay: CMTimeAdd(kCMTimeZero, CMTime(seconds: 30.0, preferredTimescale: 100000)), timeEnd: CMTimeAdd(kCMTimeZero, CMTime(seconds: 30.0, preferredTimescale: 100000)), musicAsset: splashign_Around, musicName: "Humidity", coverImage: #imageLiteral(resourceName: "humidity_albumJacket.jpg"),url: url)
		musics += [music]
		self.selectedMusic = musics[0]
	}
	
	override	public func numberOfSections(in tableView: UITableView) -> Int{
		return 1
	}
	override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return musics.count
	}
	override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
		
		let cellIdentifier = "MusicTableViewCell"
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MusicTableViewCell  else {
			fatalError("The dequeued cell is not an instance of MusicTableViewCell.")
		}
		
		let music = musics[indexPath.row]
		
		cell.musicName.text = music.musicName
		cell.musicImage.image = music.coverImage
		let waveform:FDWaveformView = 	cell.waveform
		waveform.delegate = self
		waveform.alpha = 1
		waveform.audioURL = music.url
		waveform.zoomSamples = 0 ..< waveform.totalSamples / 3
		waveform.doesAllowScrubbing = false
		waveform.doesAllowStretch = false
		waveform.doesAllowScroll = false
		updateWaveformTypeButtons()
		
		return cell
	}
	
	
	override public func tableView(_ tableView: UITableView, didSelectRowAt		indexPath: IndexPath)
 {
	self.selectedMusic = musics[indexPath.row]
	if let selectedMusic = self.selectedMusic{
		let playerItem = AVPlayerItem( url:selectedMusic.url! )
		player = AVPlayer(playerItem:playerItem)
		player.rate = 1.0;
		player.play()
	}
	}
	
	func updateWaveformTypeButtons() {
		/* TODO: Make this public and then use it here
		let (selectedButton, nonSelectedButton): (UIButton, UIButton) = {
		switch waveform.waveformType {
		case .linear: return (linearButton, logarithmicButton)
		case .logarithmic: return (logarithmicButton, linearButton)
		}
		}()
		selectedButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
		selectedButton.layer.borderWidth = 2
		nonSelectedButton.layer.borderWidth = 0
		*/
	}
	override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
			if segue.identifier == "MusicSelect" {
			let VC = (segue.destination as! ViewController)
			VC.mySelectedAsset.myBGM = selectedMusic!
		}
		
	}
	@IBOutlet var songTable: UITableView!
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		loadSampleMusics()
	}
	
}

