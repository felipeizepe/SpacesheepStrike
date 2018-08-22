//
//  ConnectionService.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 17/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import NetworkExtension
import SceneKit


protocol RoomStateDelegate {
	func roomStateChanged(connectedDevices: [String])
	func startGame()
}

protocol GameDataDelegate {
	func receiveMotion(node: SCNVector3?)
	func connectedDevicesChanged( connectedDevices: [String])
}

class ConnectionService: NSObject {
	
	internal let myPeerID = ConnectionConstants.peerID
	internal var session: MCSession!
	private var isConnected = false
	private var gameStarted = false
	private(set) var isStreaming = false
	internal var outputStream: OutputStream?
	
	var err: NSError?
	
	//Delegate
	var roomStateDelegate: RoomStateDelegate?
	var gameDataDelegate: GameDataDelegate?
	
	func getPlayersList() -> [String] {
		return session.connectedPeers.map{$0.displayName}
	}
	
	public func send(node: SCNVector3) {
//		//		NSLog("%@", "to \(session.connectedPeers.count) peers")
//
//		if session.connectedPeers.count > 0 {
//			do {
//				let data  = NSKeyedArchiver.archivedData(withRootObject: node)
//				try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
//			}
//			catch let error {
//				NSLog("%@", "Error for sending: \(error)")
//			}
//		}
		
		let data = NSKeyedArchiver.archivedData(withRootObject: node)
		//write in the output stream the bytes array of the NSData
		if let output = outputStream {
			let result = data.withUnsafeBytes { dataBytes in
				output.write(UnsafePointer(dataBytes), maxLength: data.count)
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
				self.isConnected = true
			}
			catch let error {
				NSLog("%@", "Error for sending: \(error)")
			}
		}
	}
	
	public func isConnectionActive() -> Bool {
		return self.isConnected
	}
	
	public func disconnectFromSession() {
		self.session.disconnect()
	}
	
	func startGame() {
		// TODO: start game here
		do {
			try self.outputStream = session.startStream(withName: "Game-Stream", toPeer: session.connectedPeers.first!)
			if let stream = outputStream {
				stream.delegate = self
				stream.schedule(in: RunLoop.current, forMode: .default)
				stream.open()
				isStreaming = true
			}
		} catch  {
			print(error)
		}
		
	}
}

extension ConnectionService: MCSessionDelegate {
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
		
		if state == .notConnected {
			self.isConnected = false
		}else if state == .connected {
			self.isConnected = true
		}
		
		if let delegate = roomStateDelegate {
			delegate.roomStateChanged(connectedDevices: session.connectedPeers.map{$0.displayName})
		}
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("%@", "didReceiveData: \(data)")
		//self.delegate?.motionChanged(manager: self, motion: receivedMotion)
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
			if let receivedNode = NSKeyedUnarchiver.unarchiveObject(with: data) as? SCNVector3? {
				if let delegate = self.gameDataDelegate {
					delegate.receiveMotion(node: receivedNode)
				}
			}
		}
		
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		NSLog("%@", "didReceiveStream")
		stream.delegate = self
		stream.schedule(in: RunLoop.current, forMode: .default)
		stream.open()
		if !isStreaming {
			self.startGame()
		}
		self.sendStartGameSignal()
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		NSLog("%@", "didStartReceivingResourceWithName")
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		NSLog("%@", "didFinishReceivingResourceWithName")
	}
}


extension ConnectionService: StreamDelegate {
	func stream(aStream: Stream, handleEvent eventCode: Stream.Event) {
		print("RECEIVED: \(eventCode)")
		switch(eventCode){
		case Stream.Event.hasBytesAvailable:
			let input = aStream as! InputStream
			var buffer = [UInt8](repeating: 0, count: 1024) //allocate a buffer. The size of the buffer will depended on the size of the data you are sending.
			let numberBytes = input.read(&buffer, maxLength:1024)
			let dataString = NSData(bytes: &buffer, length: numberBytes)
			if let receivedNode = NSKeyedUnarchiver.unarchiveObject(with: dataString as Data) as? SCNVector3 {//deserializing the NSData
				if let delegate = self.gameDataDelegate {
					delegate.receiveMotion(node: receivedNode)
				}
			}
			
		//input
		case Stream.Event.hasSpaceAvailable:
			break
		//output
		default:
			break
		}
	}
}
