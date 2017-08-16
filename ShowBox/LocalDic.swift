//
//  LocalDic.swift
//  ShowBox
//
//  Created by snow on 2017. 8. 14..
//  Copyright © 2017년 snow. All rights reserved.
//

import Foundation
import Photos

var LocalDic:[Int: String] = [:]
var LocalImageDIc:[Int:UIImage] = [:]

func convertToAddressWith(key:Int,coordinate: CLLocation) {
	
	let geoCoder = CLGeocoder()
	
	geoCoder.reverseGeocodeLocation(coordinate) { (placemarks, error) -> () in
		if error != nil {
			NSLog("\(String(describing: error))")
			return
		}
		guard let placemark = placemarks?.first,
			let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String] else {
				return
		}
		let address = addrList.joined(separator: " ")
		LocalDic[key] = address
		print (address)
		//	return address
	}
	DispatchQueue.global().async {
	LocalImageDIc[key] = getMapImage(lat: coordinate.coordinate.latitude, long: coordinate.coordinate.longitude)
	}
}

func getMapImage(lat:Double,long:Double)->UIImage?{
	let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:green|\(lat),\(long)&\("zoom=15&size=\(2 * Int(500))x\(2 * Int(500))")&sensor=true"
	var image:UIImage? = nil
	let url = URL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
	do {
		let data = try NSData(contentsOf: url!, options: NSData.ReadingOptions())
		image = UIImage(data: data as Data)
	} catch {
		image = nil
	}
	return image
}
