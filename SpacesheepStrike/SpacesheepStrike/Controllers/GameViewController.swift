//
//  GameViewController.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 03/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import CoreMotion

class GameViewController: UIViewController {
	@IBOutlet weak var scnView: SCNView!
	@IBOutlet weak var dataLabel: UILabel!
	@IBOutlet weak var sessionOwnerLabel: UILabel!
	let multipeerConnectivityService: MultipeerConnectivityService = MultipeerConnectivityService()
	var roll: Float = 0
	var pitch: Float = 0
	var yaw: Float = 0
	var enemy: SCNNode!
	var ship: Spaceship!
	
	//MARK: Lifecycle mehtods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// create a new scene
		let scene = SCNScene(named: "GameScene.scn")!
		let camera = scene.rootNode.childNode(withName: "camera", recursively: true)!
		enemy = scene.rootNode.childNode(withName: "enemy", recursively: true)!
		if let shipNode = scene.rootNode.childNode(withName: "ShipNode", recursively: true) {
			ship = Spaceship(spaceshipNode: shipNode)
		} else {
			print("ERRO - NAVE NÃO ENCONTRADA")
			return
		}
		// retrieve the SCNView
		let scenarioService = ScenarioService.init()
		scenarioService.generateScenario(scene: scene, row: 20, column: 20)
		
		// set the scene to the view
		scnView.scene = scene

		scnView.delegate = self
		scnView.isPlaying = true
		scnView.pointOfView = camera
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = false
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true
		
		// add a tap gesture recognizer
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
		
		// configure the view
		scnView.backgroundColor = UIColor.white
	}
	
	//MARK: Outlets methods
	@objc
	func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		// retrieve the SCNView
		if let bullet = ship.createProjectile() {
			scnView.scene?.rootNode.addChildNode(bullet)
		}
	}
	
	/// Start the services needed
	func setupServices() {
		self.multipeerConnectivityService.delegate = self
	}
	
	//MARK: Device Options
	override var shouldAutorotate: Bool {
		return false
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return .allButUpsideDown
		} else {
			return .all
		}
	}
	
}

extension GameViewController: SCNSceneRendererDelegate {
	func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
		//Moves and rotates the ship based on the deviced rotation information
		if var deviceQuaternion = CoreMotionService.shared.deviceQuaternion{
			deviceQuaternion.y -= GameConstants.phoneInitialInclination
			deviceQuaternion.restrict(restrictionValue: GameConstants.rotationMax)
			let scnQuaterion = SCNQuaternion(-deviceQuaternion.y * 2.0, 0, -deviceQuaternion.x * 2.0, deviceQuaternion.w)
			
			ship.moveInRelation(toQuaternion: scnQuaterion)
		}
		
		//Send information to opponent
		if let att = CoreMotionService.shared.attitude {
			//self.multipeerConnectivityService.send(motion: att)
		}
	}
}

extension GameViewController: MultipeerConnectivityServicesDelegate {
	func showNode() {
		print("Show Node Function working")
	}
	
	func connectedDevicesChanged(manager: MultipeerConnectivityService, connectedDevices: [String]) {
		OperationQueue.main.addOperation {
			self.sessionOwnerLabel.text = "Connections: \(connectedDevices)"
		}
	}
	
	func motionChanged(manager: MultipeerConnectivityService, motion: CMAttitude?) {
		// TODO: Implement the filter for old messages to be ignored if their ∆t is too high
		self.roll = Float(motion!.roll)
		self.pitch = Float(motion!.pitch)
		self.yaw = Float(motion!.yaw)
		
		// TODO: Interpolate values for better frame rate
		OperationQueue.main.addOperation {
			self.enemy.runAction(SCNAction.rotateTo(x: CGFloat(self.roll), y: CGFloat(self.pitch), z: CGFloat(self.yaw), duration: 1/60))
		}
	}
}
