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

class ViewController: UIViewController, TLPhotosPickerViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate{

	@IBOutlet var toDatePicker: UIPickerView!
	@IBOutlet var fromDatePicker: UIDatePicker!
	var timediff:TimeInterval = 9*60*60
    var mySelectedAsset:TimeLine = TimeLine()
    var destinationVC:TLPhotosPickerViewController? = nil
    var calender:Calendar = Calendar(identifier: .gregorian)
	var toDate:Date = Date()
	//@IBOutlet var toDatePicker: UIPickerView!
	var pickerData:[String] = ["하루","이틀","사흘","나흘","닷새","엿새","일주일"]
    override func viewDidLoad() {
        super.viewDidLoad()
        toDatePicker.dataSource = self
		toDatePicker.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func fromDateChanged(_ sender: UIDatePicker) {

		destinationVC?.refetchLibrary(fromDate: fromDatePicker.date.addingTimeInterval(timediff), toDate: toDate) //임시방편으로 시간 수정 GMT기준으로 더해줘야할듯.
        
    }
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerData.count;
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		toDate = fromDatePicker.date.addingTimeInterval(TimeInterval(row * 24*60*60))
		//destinationVC?.refetchLibrary(fromDate: fromDatePicker.date.addingTimeInterval(timediff), toDate: toDate)
		return pickerData[row]
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
		if segue.identifier == "ShowBox" {
			let SVC = (segue.destination as! ShowBoxViewController)
			SVC.selectedAsset = self.mySelectedAsset
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
		performSegue(withIdentifier: "ShowBox", sender: nil)
		
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
		fromDatePicker.minimumDate = startDate
		fromDatePicker.maximumDate = endDate
		fromDatePicker.date = startDate
		let days = Int(endDate.timeIntervalSince1970 -  startDate.timeIntervalSince1970)/(24*60*60)
		for i in 7..<days{
		pickerData.append(String(format:"%d일",i))
		}
		toDatePicker.reloadAllComponents()
		
		toDatePicker.selectRow(days-1, inComponent: 0, animated: true)
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

