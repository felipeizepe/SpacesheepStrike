//
//  RoomViewCell.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 16/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import UIKit

class RoomViewCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	var room: Room?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
	func setupRoom(cellRoom room: Room){
		self.room = room
		self.nameLabel.text = room.name
	}
	
	func setupPlayer( playerName: String) {
		self.nameLabel.text = playerName
	}
	
}

