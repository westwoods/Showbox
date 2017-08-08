//
//  SongTableView.swift
//  ShowBox
//
//  Created by snow on 2017. 8. 7..
//  Copyright © 2017년 snow. All rights reserved.
//

import UIKit
import FDWaveformView
class MusicTableViewCell:UITableViewCell{

	@IBOutlet var musicName: UILabel!
	
	@IBOutlet var musicImage: UIImageView!
//MARK: Properties
	@IBOutlet var waveFormPlot: UIView!
    
 
	@IBOutlet weak var waveform:FDWaveformView!
}
