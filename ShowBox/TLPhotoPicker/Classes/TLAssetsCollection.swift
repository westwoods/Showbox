//
//  TLAssetsCollection.swift
//  TLPhotosPicker
//
//  Created by wade.hawk on 2017. 4. 18..
//  Copyright © 2017년 wade.hawk. All rights reserved.
//

import Foundation
import Photos
import PhotosUI

public class TLPHAsset {
	enum CloudDownloadState {
		case ready,progress,complete,failed
	}
	var state = CloudDownloadState.ready
	
	public enum AssetType {
		case photo,video,livePhoto
	}
	public var phAsset: PHAsset? = nil
	public var selectedOrder: Int = 0
	public var clusterGroup:Int = -1
	public var selectedHighLight: Int = 0  //0 nomal 1 selected 2 highlighted
	public var faceFeatureFilter:[TimeAsset.FaceFeatures] = []
	public var type: AssetType {
		get {
			guard let phAsset = self.phAsset else { return .photo }
			if phAsset.mediaSubtypes.contains(.photoLive) {
				return .livePhoto
			}else if phAsset.mediaType == .video {
				return .video
			}else {
				return .photo
			}
		}
	}
	public var fullResolutionImage: UIImage? {
		get {
			guard let phAsset = self.phAsset else { return nil }
			return TLPhotoLibrary.fullResolutionImageData(asset: phAsset)
		}
	}
	public var originalFileName: String? {
		get {
			guard let phAsset = self.phAsset,let resource = PHAssetResource.assetResources(for: phAsset).first else { return nil }
			return resource.originalFilename
		}
	}
	public var faces:[CIFeature]? = nil{
	 didSet(oldValue){
		if let faces = faces{
			if faces.count > 2
			{
				//얼굴이 많음.
				faceFeatureFilter.append(.many)
			}
			for face in faces{
				if let face = face as? CIFaceFeature{
					if !face.rightEyeClosed && !face.leftEyeClosed {
						faceFeatureFilter.append(.eye)
					}
					if face.hasSmile {
						faceFeatureFilter.append(.smile)
					}                        // Apply the transform to convert the coordinates
				}
			}
		}
		else{
			faceFeatureFilter.append(.none)
		}
		}
	}
	init(asset: PHAsset?) {
		self.phAsset = asset
	}
}

class TLAssetsCollection {
	var fetchResult: PHFetchResult<PHAsset>? = nil
	var WWAssetsDic:[Int:TLPHAsset] = [:]
	var thumbnail: UIImage? = nil
	var useCameraButton: Bool = false
	var recentPosition: CGPoint = CGPoint.zero
	var title: String
	var localIdentifier: String
	var startDate: Date?
	var endDate: Date?
	var count: Int {
		get {
			guard let count = self.fetchResult?.count, count > 0 else { return 0 }
			return count + (self.useCameraButton ? 1 : 0)
		}
	}
	
	init(collection: PHAssetCollection) {
		self.title = collection.localizedTitle ?? ""
		self.localIdentifier = collection.localIdentifier
		
	}
	
	
	init() {
		self.title = "allphotos"
		self.localIdentifier = ""
		
	}
	
	func getAsset(at index: Int) -> PHAsset? {
		if self.useCameraButton && index == 0 { return nil }
		let index = index - (self.useCameraButton ? 1 : 0)
		return self.fetchResult?.object(at: max(index,0))
	}
	
	func getTLAsset(at index: Int) -> TLPHAsset? {
		if self.useCameraButton && index == 0 { return nil }
		let index = index - (self.useCameraButton ? 1 : 0)
		guard let asset = self.fetchResult?.object(at: max(index,0)) else { return nil }
		if let resultTLAsset = WWAssetsDic[index]
		{
			return resultTLAsset
		}
		else
		{
			WWAssetsDic[index] = TLPHAsset(asset:asset)
			
			return WWAssetsDic[index]
		}
	}
	
	func getAssets(at range: CountableClosedRange<Int>) -> [PHAsset]? {
		let lowerBound = range.lowerBound - (self.useCameraButton ? 1 : 0)
		let upperBound = range.upperBound - (self.useCameraButton ? 1 : 0)
		return self.fetchResult?.objects(at: IndexSet(integersIn: max(lowerBound,0)...min(upperBound,count)))
	}
	
	static func ==(lhs: TLAssetsCollection, rhs: TLAssetsCollection) -> Bool {
		return lhs.localIdentifier == rhs.localIdentifier
	}
}
