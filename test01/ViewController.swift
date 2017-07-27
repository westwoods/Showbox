//
//  ViewController.swift
//  test01
//
//  Created by snow on 2017. 7. 24..
//  Copyright © 2017년 snow. All rights reserved.
//

import UIKit
import TLPhotoPicker
import Photos
import AVFoundation

class ViewController: UIViewController, TLPhotosPickerViewControllerDelegate{
    var myVideoAsset:[AVAsset] = []
    var myPhotoAsset:[UIImage] = []
    var myAudioAsset:[AVAudioMix] = []
    lazy var imageManager = {
        return PHCachingImageManager()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    let dateFormatter = DateFormatter()
    
    
    var selectedAssets = [TLPHAsset]()
    @IBAction func pickerButtonTap() {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        //var configure = TLPhotosPickerConfigure()
        //configure.nibSet = (nibName: "CustomCell_Instagram", bundle: Bundle.main) // If you want use your custom cell..
        self.present(viewController, animated: true, completion: nil)
    }
    //TLPhotosPickerViewControllerDelegate
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
        
        for a in self.selectedAssets{
            print (a.originalFileName!)
            let options = PHVideoRequestOptions()
            if a.type == TLPHAsset.AssetType.video{
                imageManager.requestAVAsset(forVideo: a.phAsset!, options: options, resultHandler: { (AVAsset, AVAudioMix, info) in
                    self.myVideoAsset.append( AVAsset!)
                    print( self.myVideoAsset.count , self.myPhotoAsset.count,self.selectedAssets.count)
                    if(self.myVideoAsset.count + self.myPhotoAsset.count == self.selectedAssets.count)
                    {
                        VideoWriter.mergeVideo(myVideoAsset: self.myVideoAsset,myPhotoAsset: self.myPhotoAsset)
                        
                        self.myVideoAsset.removeAll()
                        self.myPhotoAsset.removeAll()
                    }
                })
            }
            else if  a.type == TLPHAsset.AssetType.photo{
                PHImageManager.default().requestImage(
                for:a.phAsset!, targetSize: CGSize(width: 300.0, height: 300.0), contentMode: .aspectFill, options: nil) { (UIImage, info) in
                    self.myPhotoAsset.append(UIImage!)
                    print( self.myVideoAsset.count , self.myPhotoAsset.count,self.selectedAssets.count)
                    if(self.myVideoAsset.count + self.myPhotoAsset.count == self.selectedAssets.count)
                    {
                        VideoWriter.mergeVideo(myVideoAsset: self.myVideoAsset,myPhotoAsset: self.myPhotoAsset)
                        
                        self.myVideoAsset.removeAll()
                        self.myPhotoAsset.removeAll()
                    }
                }
            }
        }
    }
    
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        // if you want to used phasset.
    }
    func photoPickerDidCancel() {
        // cancel
    }
    func dismissComplete() {
        // picker viewcontroller dismiss completion
    }
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

