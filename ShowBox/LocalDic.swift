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
}
