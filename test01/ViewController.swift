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
        let semaphore = DispatchSemaphore(value: 0)

        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
        for i in 0..<self.selectedAssets.count{
            if (self.selectedAssets[i].type == TLPHAsset.AssetType.video){
                self.videoCount += 1
            }
        }
        for i in 0..<self.selectedAssets.count{
            let options = PHVideoRequestOptions()
            if (self.selectedAssets[i].type == TLPHAsset.AssetType.video){
                imageManager.requestAVAsset(forVideo: self.selectedAssets[i].phAsset!, options: options, resultHandler: { (AVAsset, AVAudioMix, info) in
                    self.myVideoAsset.append( AVAsset!) //비디오타입 PHAsset -> AVAsset 변환작업
                    if(self.myVideoAsset.count == self.videoCount )
                    {
                        semaphore.wait()
                        VideoWriter.mergeVideo(myVideoAsset: self.myVideoAsset,myPhotoAsset: self.myPhotoAsset)
                  //  VideoWriter.exportAsset(asset: self.myVideoAsset[0])
                        self.myVideoAsset.removeAll()
                        self.myPhotoAsset.removeAll()
                        self.videoCount = 0
                        
                    }
                })
            }
            else  if  (self.selectedAssets[i].type == TLPHAsset.AssetType.photo){
                print(self.selectedAssets[i].fullResolutionImage?.size.width ?? "이미지가 없다")
                self.myPhotoAsset.append(self.selectedAssets[i].fullResolutionImage!)

            }
            if(self.myPhotoAsset.count == self.selectedAssets.count - self.videoCount)
            {
                semaphore.signal()
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

