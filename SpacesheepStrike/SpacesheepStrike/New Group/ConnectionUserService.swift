//
//  ConnectionUserService.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 15/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol RoomsSearchDelegate {
	func updateRooms(rooms: [Room])
}

class ConnectionUserService: ConnectionService {
	
	//MARK: Connectiom properties
	private let MultipeerServiceType = ConnectionConstants.roomServiceTypeName
	private var serviceBrowser: MCNearbyServiceBrowser!
	
	//MARK: other properties
	static var shared: ConnectionUserService = ConnectionUserService()
	var foundRooms: [Room] = [Room]()
	
	//Delegate
	var roomSearchDelegate: RoomsSearchDelegate?
	
	//MARK: Lifecycle Methods
	
	private override init() {
		super.init()
	}
	
	
	func startSearch() {
		self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerServiceType)
		self.serviceBrowser.delegate = self
		self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
		self.session.delegate = self
		self.serviceBrowser.startBrowsingForPeers()
	}
	
	func stopSearch() {
		self.serviceBrowser.stopBrowsingForPeers()
	}
	
	func connectToRoom(room: Room) {
		self.serviceBrowser.invitePeer(room.peerID, to: self.session, withContext: nil, timeout: ConnectionConstants.connectionTimeOut)
	}
	
}

extension ConnectionUserService: MCNearbyServiceBrowserDelegate {
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("%@", "foundPeer: \(peerID)")
		NSLog("%@", "invitePeer: \(peerID)")
		
		var room: Room
		
		if let nameInfo = info {
			room = Room(peer: peerID, roomName: nameInfo[ConnectionConstants.roomNameIdentifier], serviceType: self)
		}else {
			room = Room(peer: peerID, roomName: nil, serviceType: self)
		}
		
		foundRooms.append(room)
		if let delegate = roomSearchDelegate {
			delegate.updateRooms(rooms: self.foundRooms)
		}
		//browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("%@", "lostPeer: \(peerID)")
		
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
	}
}
