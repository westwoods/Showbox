//
//  MusicTimeTable.swift
//  ShowBox
//
//  Created by snow on 2017. 8. 8..
//  Copyright © 2017년 snow. All rights reserved.
//

import Foundation
import AVFoundation
 class MusicTimeTable{
	
	static var splashing_Around:[CMTime] = []

	init(){
		MusicTimeTable.splashing_Around.append(kCMTimeZero)
		MusicTimeTable.splashing_Around.append(CMTime(seconds: 5.307, preferredTimescale: 44100))
		
		MusicTimeTable.splashing_Around.append( CMTime(seconds: 9.607, preferredTimescale: 44100))
		
		MusicTimeTable.splashing_Around.append(CMTime(seconds: 11.607, preferredTimescale: 44100))
		
		
		MusicTimeTable.splashing_Around.append(CMTime(seconds: 19.307, preferredTimescale: 44100))
		
		
		MusicTimeTable.splashing_Around.append(CMTime(seconds: 24.007, preferredTimescale: 44100))
		
		
		MusicTimeTable.splashing_Around.append(CMTime(seconds: 33.707, preferredTimescale: 44100))
		
		
		MusicTimeTable.splashing_Around.append(CMTime(seconds: 40.451, preferredTimescale: 44100))
		
	
	
	}
	
	
	


}
