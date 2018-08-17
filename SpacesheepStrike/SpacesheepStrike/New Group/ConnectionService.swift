//
//  ConnectionService.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 17/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import MultipeerConnectivity


protocol RoomStateDelegate {
	func roomStateChanged(connectedDevices: [String])
}

class ConnectionService: NSObject {
	
	internal let myPeerID = ConnectionConstants.peerID
	internal var session: MCSession!
	
	//Delegate
	var roomStateDelegate: RoomStateDelegate?
	
	func getPlayersList() -> [String] {
		return session.connectedPeers.map{$0.displayName}
	}
	
}

extension ConnectionService: MCSessionDelegate {
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
