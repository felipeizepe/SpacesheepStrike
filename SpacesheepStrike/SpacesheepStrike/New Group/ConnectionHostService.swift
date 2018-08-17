//
//  ConnectionHostService.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 15/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ConnectionHostService: ConnectionService {
	// Service type must be a unique string, at most 15 characters long
	// and can contain only ASCII lowercase letters, numbers and hyphens.
	//MARK: Connectiom properties
	private let MultipeerServiceType = ConnectionConstants.roomServiceTypeName
	private var serviceAdvertiser: MCNearbyServiceAdvertiser!
	
	//MARK: other properties
	static var shared: ConnectionHostService = ConnectionHostService()
	var room: Room?
	
	//MARK: Lifecycle Methods
	
	private override init() {
		super.init()
	}
	
	//MARK: Auxiliary methods
	
	func createRoom(named: String) {
		var info = [String:String]()
		info[ConnectionConstants.roomNameIdentifier] = named
		self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: info, serviceType: MultipeerServiceType)
		self.serviceAdvertiser.delegate = self
		self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
		self.session.delegate = self
		self.room = Room(peer: self.myPeerID, roomName: named, serviceType: self)
		
		self.serviceAdvertiser.startAdvertisingPeer()
	}
	
	func startGame() {
		self.serviceAdvertiser.stopAdvertisingPeer()
		// TODO: start game here
	}
	
	func cancelHost() {
		self.serviceAdvertiser.stopAdvertisingPeer()
	}
	
}


extension ConnectionHostService: MCNearbyServiceAdvertiserDelegate {
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
		invitationHandler(true, self.session)
	}
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
	}
}



