//
//  ConnectionHostService.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 15/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol RoomStateDelegate {
	func roomStateChanged(connectedDevices: [String])
}

class ConnectionHostService: NSObject {
	// Service type must be a unique string, at most 15 characters long
	// and can contain only ASCII lowercase letters, numbers and hyphens.
	//MARK: Connectiom properties
	private let MultipeerServiceType = ConnectionConstants.hostServiceTypeName
	private let myPeerID = ConnectionConstants.peerID
	private var serviceAdvertiser: MCNearbyServiceAdvertiser!
	private var session: MCSession!
	
	//MARK: other properties
	static var shared: ConnectionHostService = ConnectionHostService()
	
	
	//Delegate
	var roomStateDelegate: RoomStateDelegate?
	
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


extension ConnectionHostService: MCSessionDelegate {
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
		if let delegate = roomStateDelegate {
			delegate.roomStateChanged(connectedDevices: session.connectedPeers.map{$0.displayName})
		}
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("%@", "didReceiveData: \(data)")
		//self.delegate?.motionChanged(manager: self, motion: receivedMotion)
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		NSLog("%@", "didReceiveStream")
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		NSLog("%@", "didStartReceivingResourceWithName")
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		NSLog("%@", "didFinishReceivingResourceWithName")
	}
}
