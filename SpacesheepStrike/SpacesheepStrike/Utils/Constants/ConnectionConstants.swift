//
//  ConnectionConstants.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 16/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct ConnectionConstants {
	
	
	static let roomServiceTypeName = "room-stream"
	static let roomNameIdentifier = "roomName"
	static let peerID = MCPeerID(displayName: UIDevice.current.name + UIDevice.current.systemName)
	static let connectionTimeOut: TimeInterval = 20
	
}
