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
    var videoReady = false
    var imageReady = false
    var videoCount = 0
    var imageCount = 0
    lazy var imageManager = {
        return PHCachingImageManager()
    }()
    lazy var imageManager1 = {
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
        for i in 0..<self.selectedAssets.count{
            
            if (self.selectedAssets[i].type == TLPHAsset.AssetType.video){
                self.videoCount += 1
                self.imageCount += 1
            }
        }
        for i in 0..<self.selectedAssets.count{
            let options = PHVideoRequestOptions()
            let ioptions = PHImageRequestOptions()
            if (self.selectedAssets[i].type == TLPHAsset.AssetType.video){
                imageManager.requestAVAsset(forVideo: self.selectedAssets[i].phAsset!, options: options, resultHandler: { (AVAsset, AVAudioMix, info) in
                    self.myVideoAsset.append( AVAsset!) //비디오타입 PHAsset -> AVAsset 변환작업
                    print( "video i=",i, self.selectedAssets[i].originalFileName!,self.selectedAssets[i].type,self.myVideoAsset.count , self.myPhotoAsset.count,self.selectedAssets.count,self.imageCount,self.videoCount)
                    if(self.myVideoAsset.count == self.videoCount )
                    {
                        
                    }
                })
            }
            if  (self.selectedAssets[i].type == TLPHAsset.AssetType.photo){
                      print( "photo i=",i,self.selectedAssets[i].originalFileName!,self.selectedAssets[i].type, self.myVideoAsset.count , self.myPhotoAsset.count,self.selectedAssets.count,self.imageCount,self.videoCount)
                    imageManager.requestImage(for:self.selectedAssets[i].phAsset!, targetSize: CGSize(width: 300.0, height: 300.0), contentMode: .aspectFill, options: ioptions , resultHandler:  { (UIImage, info) in
                      print("왜 두번이 불리는지 모르겠네 아아", UIImage?.size)
                    self.myPhotoAsset.append(UIImage!) //포토타입 PHAsset -> UIImage 변환작업
                   // print( "photo i=",i,self.selectedAssets[i].originalFileName!,self.selectedAssets[i].type, self.myVideoAsset.count , self.myPhotoAsset.count,self.selectedAssets.count,self.imageCount,self.videoCount)
                    if( self.imageCount == self.myPhotoAsset.count)
                    {
                    }
                })
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

