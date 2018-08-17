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
	var service: ConnectionService
	
	// MARK: lifecycle methods
	
	init(peer: MCPeerID, roomName: String?, serviceType: ConnectionService) {
		self.peerID = peer
		self.name = roomName
		self.service = serviceType
	}
	
}
