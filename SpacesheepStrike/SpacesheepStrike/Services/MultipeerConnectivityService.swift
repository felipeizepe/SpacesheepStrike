//
//  ShipServices.swift
//  ShipSensorMovementStream
//
//  Created by Richard Vaz da Silva Netto on 31/07/18.
//  Copyright © 2018 Richard Vaz da Silva Netto. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreMotion

protocol MultipeerConnectivityServicesDelegate {
	func connectedDevicesChanged(manager : MultipeerConnectivityService, connectedDevices: [String])
	func motionChanged(manager : MultipeerConnectivityService, motion: CMAttitude?)
	func showNode()
}

class MultipeerConnectivityService: NSObject {
	// Service type must be a unique string, at most 15 characters long
	// and can contain only ASCII lowercase letters, numbers and hyphens.
	private let MultipeerServiceType = "position-stream"
	private let myPeerID = MCPeerID(displayName: UIDevice.current.name + UIDevice.current.systemName)
	private let serviceAdvertiser: MCNearbyServiceAdvertiser
	private let serviceBrowser: MCNearbyServiceBrowser
	lazy var session: MCSession = {
		let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	var delegate: MultipeerConnectivityServicesDelegate?
	
	override init() {
		self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerServiceType)
		self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerServiceType)
		super.init()
		// Advertiser
		self.serviceAdvertiser.delegate = self
		// Browser
		self.serviceBrowser.delegate = self
	}
	
	deinit {
		self.serviceAdvertiser.stopAdvertisingPeer()
		self.serviceBrowser.stopBrowsingForPeers()
	}
	
	public func send(motion: CMAttitude) {
//		NSLog("%@", "to \(session.connectedPeers.count) peers")
		
		if session.connectedPeers.count > 0 {
			do {
				let data  = NSKeyedArchiver.archivedData(withRootObject: motion)
				try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
			}
			catch let error {
				NSLog("%@", "Error for sending: \(error)")
			}
		}
	}
//
//	func startAdvertising() {
//		self.serviceAdvertiser.startAdvertisingPeer()
//	}
//
//	func stopAdvertising() {
//		self.serviceAdvertiser.stopAdvertisingPeer()
//	}
//
//	func startBrowsing() {
//		self.serviceBrowser.startBrowsingForPeers()
//	}
//
//	func stopBrowsing() {
//		self.serviceBrowser.stopBrowsingForPeers()
//	}
}

extension MultipeerConnectivityService: MCNearbyServiceAdvertiserDelegate {
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
		invitationHandler(true, self.session)
	}
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
	}
}

extension MultipeerConnectivityService: MCNearbyServiceBrowserDelegate {
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("%@", "foundPeer: \(peerID)")
		NSLog("%@", "invitePeer: \(peerID)")
		browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
		delegate?.showNode()
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		NSLog("%@", "lostPeer: \(peerID)")
		
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
	}
}

extension MultipeerConnectivityService: MCSessionDelegate {
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
		delegate?.connectedDevicesChanged(manager: self, connectedDevices: session.connectedPeers.map{$0.displayName})
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		NSLog("%@", "didReceiveData: \(data)")
		let receivedMotion = NSKeyedUnarchiver.unarchiveObject(with: data) as! CMAttitude?
		self.delegate?.motionChanged(manager: self, motion: receivedMotion)
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




















