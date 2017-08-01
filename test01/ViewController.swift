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
    @IBOutlet var fromDatePicker: UIDatePicker!
    @IBOutlet var toDatePicker: UIDatePicker!
    var myVideoAsset:[AVAsset] = []
    var myPhotoAsset:[UIImage] = []
    var myAudioAsset:[AVAudioMix] = []
    var videoReady = false
    var imageReady = false
    var videoCount = 0
    var destinationVC:TLPhotosPickerViewController? = nil
    lazy var imageManager = {
        return PHCachingImageManager()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func fromDateChanged(_ sender: UIDatePicker) {
        print (sender.date)
        if( sender.date > toDatePicker.date )
        {
            toDatePicker.date = sender.date //to date가 지금 시간보다 작지않도록 설정
        }
        destinationVC?.refetchLibrary(fromDate: fromDatePicker.date, toDate: toDatePicker.date)

    }
    @IBAction func toDateChanged(_ sender: UIDatePicker) {
        if( sender.date < fromDatePicker.date )
        {
            fromDatePicker.date = sender.date //from date가 지금 시간보다 크지않도록 설정
        }
        
        destinationVC?.refetchLibrary(fromDate: fromDatePicker.date, toDate: toDatePicker.date)
    }
    @IBAction func CompletebuttonTapped(_ sender: UIButton) {
         destinationVC?.dismiss(done: true)
    }
    @IBAction func reselectbuttonTapped(_ sender: UIButton) {
        destinationVC?.dismiss(done: true)
    }
    
    @IBAction func MusicButtonTapped(_ sender: UIButton) {
         destinationVC?.dismiss(done: false)
    }
    let dateFormatter = DateFormatter()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedSegue" {
           destinationVC = (segue.destination as! TLPhotosPickerViewController)
            if let destinationVC = destinationVC{
            destinationVC.delegate = self
            destinationVC.configure.numberOfColumn = 5
            destinationVC.configure.usedCameraButton = false
            }
        }
    }
    var selectedAssets = [TLPHAsset]()
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
                print (self.selectedAssets[i].phAsset?.creationDate, self.selectedAssets[i].phAsset?.location)
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

