//
//  TLPhotoCollectionViewCell.swift
//  TLPhotosPicker
//
//  Created by wade.hawk on 2017. 5. 3..
//  Copyright © 2017년 wade.hawk. All rights reserved.
//

import UIKit
import PhotosUI

open class TLPlayerView: UIView {
    open var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    open var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override open static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

open class TLPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet open var imageView: UIImageView?
    @IBOutlet open var playerView: TLPlayerView?
    @IBOutlet open var livePhotoView: PHLivePhotoView?
    @IBOutlet open var liveBadgeImageView: UIImageView?
    @IBOutlet open var durationView: UIView?
    @IBOutlet open var videoIconImageView: UIImageView?
    @IBOutlet open var durationLabel: UILabel?
    @IBOutlet open var indicator: UIActivityIndicatorView?
    @IBOutlet open var selectedView: UIView?
    @IBOutlet open var selectedHeight: NSLayoutConstraint?
    @IBOutlet open var orderLabel: UILabel?
    @IBOutlet open var orderBgView: UIView?
    
    var configure = TLPhotosPickerConfigure() {
        didSet {
            self.selectedView?.layer.borderColor = self.configure.selectedColor.cgColor
            self.orderBgView?.backgroundColor = self.configure.selectedColor
            self.videoIconImageView?.image = self.configure.videoIcon
        }
    }
    
    open var isCameraCell = false
    
    open var duration: TimeInterval? {
        didSet {
            guard let duration = self.duration else { return }
            self.selectedHeight?.constant = -10
            self.durationLabel?.text = timeFormatted(timeInterval: duration)
        }
    }
    
    open var player: AVPlayer? = nil {
        didSet {
            if self.player == nil {
                self.playerView?.playerLayer.player = nil
                NotificationCenter.default.removeObserver(self)
            }else {
                self.playerView?.playerLayer.player = self.player
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil, using: { [weak self] (_) in
                    DispatchQueue.main.async {
                        guard let `self` = self else { return }
                        self.player?.seek(to: kCMTimeZero)
                        self.player?.play()
                    }
                })
            }
        }
    }
    open var faces:[CIFeature]? = nil{
        didSet(oldValue){
            
            var transform = CGAffineTransform(scaleX: 1,y: -1)
            
            guard let personciImage = CIImage(image:  (imageView?.image)!) else {
                return
            }
            let ciImageSize = personciImage.extent.size
            
            transform = transform.translatedBy(x: 0, y: -(ciImageSize.height))
            if let faces = faces{
                for face in faces{
                    if let face = face as? CIFaceFeature{
                        
                        if !face.rightEyeClosed && !face.leftEyeClosed {
                            self.durationView?.backgroundColor =  self.configure.smileColor
                            self.selectedView?.layer.borderColor = self.configure.smileColor.cgColor
                            self.orderBgView?.backgroundColor = self.configure.smileColor
                            self.orderLabel?.text = (self.orderLabel?.text)! + "E"
                            self.selectedView?.isHidden = false
                        }
                        
                        if face.hasSmile {
                            self.durationView?.backgroundColor =  self.configure.smileColor
                            self.selectedView?.layer.borderColor = self.configure.smileColor.cgColor
                            self.orderBgView?.backgroundColor = self.configure.smileColor
                            self.orderLabel?.text = (self.orderLabel?.text)! + "S"
                            self.selectedView?.isHidden = false
                        }
                        print("Found bounds are \(face.bounds)")
                        // Apply the transform to convert the coordinates
                        var faceViewBounds = face.bounds.applying(transform)
                        
                        // Calculate the actual position and size of the rectangle in the image view
                        if  let viewSize = imageView?.frame.size{
                            let scale = min(viewSize.width / (ciImageSize.width),
                                            viewSize.height / (ciImageSize.height))
                            let offsetX = (viewSize.width - (ciImageSize.width) * scale) / 2
                            let offsetY = (viewSize.height - (ciImageSize.height) * scale) / 2
                            
                            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
                            faceViewBounds.origin.x += offsetX
                            faceViewBounds.origin.y += offsetY
//
                           print("Found bounds are \(faceViewBounds)")
                            let faceBox = UIView(frame: faceViewBounds)
//                            
                            faceBox.layer.borderWidth = 2
                            faceBox.layer.borderColor = UIColor.red.cgColor
                            faceBox.backgroundColor = UIColor.clear
                            faceBox.tag = 222
                            imageView?.addSubview(faceBox)
                        }
                        
                    }
                }
            }
        }
    }
    open var selectedAsset: Int = 0 { //0 unselected 1 selected 2 highlight
        willSet(newValue) {
            switch(newValue)
            {
            case 0:
                self.selectedView?.isHidden = true
                self.durationView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
                self.orderLabel?.text = ""
            case 1:
                self.durationView?.backgroundColor =  self.configure.selectedColor
                self.selectedView?.layer.borderColor = self.configure.selectedColor.cgColor
                self.orderBgView?.backgroundColor = self.configure.selectedColor
                self.selectedView?.isHidden = false
            case 2:
                self.durationView?.backgroundColor = self.configure.hilightedColor
                self.selectedView?.layer.borderColor = self.configure.hilightedColor.cgColor
                self.selectedView?.isHidden = false
                self.orderLabel?.text = "H"
                self.orderBgView?.backgroundColor = self.configure.hilightedColor
                
                
            default:
                return
            }
            if let subviews = imageView?.subviews{
                for view in subviews
                {
                    if( view.tag == 222)
                    {
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    open func timeFormatted(timeInterval: TimeInterval) -> String {
        let seconds: Int = lround(timeInterval)
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%d:%d:%02d", hour, minute, second)
        } else {
            return String(format: "%d:%02d", minute, second)
        }
    }
    
    open func popScaleAnim() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    func stopPlay() {
        if let player = self.player {
            player.pause()
            self.player = nil
        }
        self.livePhotoView?.isHidden = true
        self.livePhotoView?.stopPlayback()
    }
    
    deinit {
        //        print("deinit TLPhotoCollectionViewCell")
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.playerView?.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.livePhotoView?.isHidden = true
        self.durationView?.isHidden = true
        self.selectedView?.isHidden = true
        self.selectedView?.layer.borderWidth = 10
        self.selectedView?.layer.cornerRadius = 15
        self.orderBgView?.layer.cornerRadius = 2
        self.videoIconImageView?.image = self.configure.videoIcon
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        self.livePhotoView?.isHidden = true
        self.durationView?.isHidden = true
        self.durationView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.selectedHeight?.constant = 10
        self.selectedAsset = 0
    }
}
