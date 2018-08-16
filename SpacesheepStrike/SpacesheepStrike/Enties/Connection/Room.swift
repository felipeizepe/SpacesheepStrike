//
//  Room.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 16/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class Room {
	
	// MARK: Properties
	
	var peerID: MCPeerID
	var name: String?
	
	// MARK: lifecycle methods
	
	init(peer: MCPeerID, roomName: String?) {
		self.peerID = peer
		self.name = roomName
	}
	
}
