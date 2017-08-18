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
		var address = addrList.joined(separator: " ")
		address = address.replacingOccurrences(of: placemark.subThoroughfare ?? "", with: "")
		address = address.replacingOccurrences(of: placemark.postalCode ?? "", with: "")
		
		address = address.replacingOccurrences(of: placemark.subAdministrativeArea ?? "", with: "")
		LocalDic[key] = address
		print (address)
		//	return address
	}
	DispatchQueue.global().async {
	LocalImageDIc[key] = getMapImage(lat: coordinate.coordinate.latitude, long: coordinate.coordinate.longitude)
	}
}

func getMapImage(lat:Double,long:Double)->UIImage?{
	let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:red|\(lat),\(long)&\("zoom=15&size=\( Int(300))x\(Int(300))")&maptype=hybrid&sensor=true&language=ko-KR&key=AIzaSyCdQ4zLfN2LsBrRsLji7QworscPYerpap8"
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
