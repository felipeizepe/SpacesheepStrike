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

class ShipViewController: UIViewController{
	
	@IBOutlet var scnView: SCNView!
	var startScene: StartScene?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		startScene = StartScene.init()
		self.scnView.scene = startScene?.scene
		self.scnView.overlaySKScene = BaseOverlay(fileNamed: "StartOverlay.sks")
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

















