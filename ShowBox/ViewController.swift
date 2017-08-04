//
//  ViewController.swift
//  test01
//
//  Created by snow on 2017. 7. 24..
//  Copyright © 2017년 snow. All rights reserved.
//

import UIKit
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
    var calender:Calendar = Calendar(identifier: .gregorian)
    lazy var imageManager = {
        return PHCachingImageManager()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func fromDateChanged(_ sender: UIDatePicker) {
        if( sender.date > toDatePicker.date )
        {
            toDatePicker.date = sender.date //to date가 지금 시간보다 작지않도록 설정
        }
        destinationVC?.refetchLibrary(fromDate: fromDatePicker.date.addingTimeInterval(9*60*60*60), toDate: toDatePicker.date.addingTimeInterval(9*60*60*60)) //임시방편으로 시간 수정 GMT기준으로 더해줘야할듯.
        
    }
    @IBAction func toDateChanged(_ sender: UIDatePicker) {
        if( sender.date < fromDatePicker.date )
        {
            fromDatePicker.date = sender.date //from date가 지금 시간보다 크지않도록 설정
        }
        
        destinationVC?.refetchLibrary(fromDate: fromDatePicker.date.addingTimeInterval(9*60*60*60), toDate: toDatePicker.date.addingTimeInterval(9*60*60*60)) //임시방편으로 시간수정 GMT기준으로 더해줘야할듯.
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
    
    
    @IBAction func exitFromViewController(_ segue: UIStoryboardSegue) {
        
        print ("welcome")
    }
    let dateFormatter = DateFormatter()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedSegue" {
            destinationVC = (segue.destination as! TLPhotosPickerViewController)
            if let destinationVC = destinationVC{
                destinationVC.delegate = self
                destinationVC.configure.numberOfColumn = 4
                destinationVC.configure.usedCameraButton = false
            }
        }
    }
    var selectedAssets = [TLPHAsset]()
    //TLPhotosPickerViewControllerDelegate
    func dismissPhotoPicker(_ withTLPHAssets: [TLPHAsset]) {
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
                        VideoWriter.mergeVideo(self.myVideoAsset,myPhotoAsset: self.myPhotoAsset)
                        //  VideoWriter.exportAsset(asset: self.myVideoAsset[0])
                        self.myVideoAsset.removeAll()
                        self.myPhotoAsset.removeAll()
                        self.videoCount = 0
                        
                    }
                })
            }
            else  if  (self.selectedAssets[i].type == TLPHAsset.AssetType.photo){
//                print(self.selectedAssets[i].fullResolutionImage?.size.width ?? "이미지가 없다")
//                print (self.selectedAssets[i].phAsset?.creationDate, self.selectedAssets[i].phAsset?.location)
                self.myPhotoAsset.append(self.selectedAssets[i].fullResolutionImage!)
                
            }
            if(self.myPhotoAsset.count == self.selectedAssets.count - self.videoCount)
            {
                semaphore.signal()
            }
        }
    }
    
    func dismissPhotoPicker(_ withPHAssets: [PHAsset]) {
        // if you want to used phasset.
    }
    func photoPickerDidCancel() {
        // cancel
    }
    func dismissComplete() {
        // picker viewcontroller dismiss completion
    }
    func didExceedMaximumNumberOfSelection(_ picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    func initDatepicker(_ startDate:Date,endDate:Date)
    {
        toDatePicker.minimumDate = startDate
		fromDatePicker.maximumDate = startDate
		
        toDatePicker.maximumDate = endDate
        fromDatePicker.maximumDate = endDate
        
        toDatePicker.date = endDate//to date가 지금 시간보다 작지않도록 설정
        fromDatePicker.date = startDate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

