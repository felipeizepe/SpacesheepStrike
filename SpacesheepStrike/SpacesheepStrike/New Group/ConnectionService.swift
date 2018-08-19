//
//  ConnectionService.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 17/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SceneKit


protocol RoomStateDelegate {
	func roomStateChanged(connectedDevices: [String])
	func startGame()
}

protocol GameDataDelegate {
	func receiveMotion(enemyNode: SCNNode?)
	func connectedDevicesChanged( connectedDevices: [String])
	func motionChanged(myNode: SCNNode?)
}

class ConnectionService: NSObject {
	
	internal let myPeerID = ConnectionConstants.peerID
	internal var session: MCSession!
	
	private var gameStarted = false
	
	//Delegate
	var roomStateDelegate: RoomStateDelegate?
	var gameDataDelegate: GameDataDelegate?
	
	func getPlayersList() -> [String] {
		return session.connectedPeers.map{$0.displayName}
	}
	
	public func send(myNode: SCNNode) {
		//		NSLog("%@", "to \(session.connectedPeers.count) peers")
		
		if session.connectedPeers.count > 0 {
			do {
				let data  = NSKeyedArchiver.archivedData(withRootObject: myNode)
				try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
			}
			catch let error {
				NSLog("%@", "Error for sending: \(error)")
			}
		}
	}
	
	public func sendStartGameSignal() {
		//		NSLog("%@", "to \(session.connectedPeers.count) peers")
		
		if session.connectedPeers.count > 0 {
			do {
				let data  = NSKeyedArchiver.archivedData(withRootObject: ConnectionConstants.startGameSignal)
				try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
				self.gameStarted = true
			}
			catch let error {
				NSLog("%@", "Error for sending: \(error)")
			}
		}
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
		if !gameStarted {
			if let startSignal = NSKeyedUnarchiver.unarchiveObject(with: data) as? Int? {
				if let delegate = roomStateDelegate {
					if startSignal == ConnectionConstants.startGameSignal {
						delegate.startGame()
						gameStarted = true
					}
				}
			}
		}else {
			if let enemyNode = NSKeyedUnarchiver.unarchiveObject(with: data) as? SCNNode? {
				if let delegate = self.gameDataDelegate {
					delegate.receiveMotion(enemyNode: enemyNode)
				}
			}
		}
		
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
