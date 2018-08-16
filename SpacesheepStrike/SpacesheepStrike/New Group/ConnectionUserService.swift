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

class ConnectionUserService: NSObject {
	
	//MARK: Connectiom properties
	private let MultipeerServiceType = ConnectionConstants.userServiceTypename
	private let myPeerID = ConnectionConstants.peerID
	private var serviceBrowser: MCNearbyServiceBrowser!
	private var session: MCSession!
	
	//MARK: other properties
	static var shared: ConnectionUserService = ConnectionUserService()
	var foundRooms: [Room] = [Room]()
	
	//Delegate
	var roomStateDelegate: RoomStateDelegate?
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
		
		if let nameInfo = info{
			room = Room(peer: peerID, roomName: nameInfo[ConnectionConstants.roomNameIdentifier])
		}else {
			room = Room(peer: peerID, roomName: nil)
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

extension ConnectionUserService: MCSessionDelegate {
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
