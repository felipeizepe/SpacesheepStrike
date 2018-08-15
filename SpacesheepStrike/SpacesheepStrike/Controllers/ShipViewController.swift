//
//  GameViewController.swift
//  ShipSensorMovementStream
//
//  Created by Richard Vaz da Silva Netto on 31/07/18.
//  Copyright © 2018 Richard Vaz da Silva Netto. All rights reserved.
//

import UIKit
import CoreMotion
import SceneKit
import SpriteKit

protocol KeyboardResponseProtocol {
	func textFieldValue(text: String)
}

class ShipViewController: UIViewController{
	
	@IBOutlet var scnView: SCNView!
	var startScene: StartScene?
	var keyboardDelegate: KeyboardResponseProtocol?
	
	@IBOutlet weak var roomNameInsertionField: UITextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		// SCNScene
		startScene = StartScene.init()
		self.scnView.scene = startScene?.scene
		// Set the start Overlay
		self.setLobbyOverlay()
		// Create Gesture to press button
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap:)))
		self.view.addGestureRecognizer(tapGesture)
    }
	
	@objc func handleTap(tap: UITapGestureRecognizer) {
		guard let overlay = self.scnView.overlaySKScene as? BaseOverlay else {
			print("Could not cast Overlay")
			return
		}
		overlay.tapReceived(location: tap.location(in: self.scnView))
		return
	}
	
}

extension ShipViewController: OverlayProtocol {
	func setStartOverlay() {
		let startOverlay = StartOverlay(fileNamed: "StartOverlay.sks")
		startOverlay?.overlayDelegate = self
		self.scnView.overlaySKScene = startOverlay
		self.scnView.overlaySKScene?.isPaused = false
	}
	
	func setLobbyOverlay() {
		let lobbyOverlay = LobbyOverlay(fileNamed: "LobbyOverlay.sks")
		lobbyOverlay?.overlayDelegate = self
//		self.keyboardDelegate = lobbyOverlay
		self.scnView.overlaySKScene = lobbyOverlay
		self.scnView.overlaySKScene?.isPaused = false
	}
	
	func setHUDLoadingOverlay() {
		print("Set HUDLoading Overlay")
	}
	
	func setHUDOverlay() {
		print("Set HUD Overlay")
	}
	
	func setEndGameOverlay() {
		print("Set EndGame Overlay")
	}
	
	
}

















