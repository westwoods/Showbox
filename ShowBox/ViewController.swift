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
	
    var mySelectedAsset:TimeLine = TimeLine()
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
		if segue.identifier == "SelectMusic" {
			let AVC = (segue.destination as! AudioViewController)
			mySelectedAsset.myBGM = AVC.selectedMusic!
		}
		
    }
    var selectedAssets = [TLPHAsset]()
	
    //TLPhotosPickerViewControllerDelegate
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
		self.selectedAssets = self.selectedAssets.sorted(by: { ($0.phAsset?.creationDate)! < ($1.phAsset?.creationDate)!}) // 받아온 이미지들을 시간순으로 정렬
		mySelectedAsset.makeTimeLine(selectedAssets: self.selectedAssets, complete: self.allFileReadyHeadler)
    }
		
	func allFileReadyHeadler(){
			self.mySelectedAsset.removeAll()
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
    func didExceedMaximumNumberOfSelection(_ picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    func initDatepicker(startDate:Date,endDate:Date)
    {
		print(startDate , endDate)
		toDatePicker.minimumDate = startDate
		fromDatePicker.minimumDate = startDate
		
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

