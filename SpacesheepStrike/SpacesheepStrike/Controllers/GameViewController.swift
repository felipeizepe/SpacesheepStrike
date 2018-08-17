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
	var theta: Float? = 0
	var omega: Float? = 0
	
	//MARK: Lifecycle mehtods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// create a new scene
		let scene = SCNScene(named: "GameScene.scn")!
		let camera = scene.rootNode.childNode(withName: "camera", recursively: true)!
		enemy = scene.rootNode.childNode(withName: "enemy", recursively: true)!
		if let shipNode = scene.rootNode.childNode(withName: "ShipNode", recursively: true) {
			ship = Spaceship(spaceshipNode: shipNode, scene: scene)
		} else {
			print("ERRO - NAVE NÃO ENCONTRADA")
			return
		}
		// retrieve the SCNView
		let scenarioService = ScenarioService.init()
		scenarioService.generateScenario(scene: scene, row: 20, column: 20)
		
		// set the scene to the view
		scnView.scene = scene
		scene.physicsWorld.contactDelegate = self
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
		
		self.setupSound()
	}
	
	//MARK: Outlets methods
	@objc
	func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		if let bullet = ship.createProjectile() {
			scnView.scene?.rootNode.addChildNode(bullet)
		}
	}
	
	/// Start the services needed
	func setupServices() {
		self.multipeerConnectivityService.delegate = self
	}
	
	
	/// Sets up de sound
	func setupSound() {
		if let music = SCNAudioSource(fileNamed: "art.scnassets/Music/Motherlode.mp3") {
			self.scnView.scene!.rootNode.runAction(SCNAction.repeatForever(SCNAction.playAudio(music, waitForCompletion: true)))
		}
		
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
			let scnQuaterion = SCNQuaternion(-deviceQuaternion.y * GameConstants.rotationFactor, 0, -deviceQuaternion.x * GameConstants.rotationFactor, deviceQuaternion.w * GameConstants.rotationFactor)
			
			ship.moveInRelation(toQuaternion: scnQuaterion, pitch: self.theta!, yaw: self.omega!)
		}
		
		//Send information to opponent
		if let att = CoreMotionService.shared.attitude {
//			//self.multipeerConnectivityService.send(motion: att)
			self.theta = Float(att.pitch / 10)
			self.omega = Float(att.roll)
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

//MARK: Contact delegate
extension GameViewController: SCNPhysicsContactDelegate {
	
	func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
		let contactMask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
		
		// first, sort out what kind of collision
		if (contactMask == (CollisionConstants.bulletCategoryMask | CollisionConstants.enemyCategoryMask)) {
			let bullet: BulletNode?
//			var enemy: SCNNode?
			// next, sort out which body is the bullet and which is the ship
			if (contact.nodeA.physicsBody?.categoryBitMask == CollisionConstants.bulletCategoryMask) {
				bullet = contact.nodeA.parent as? BulletNode
//				enemy = contact.nodeB
			} else {
				bullet = contact.nodeB.parent as? BulletNode
//				enemy = contact.nodeA
			}
			//Removes bullet
			removeNode(remove: bullet)
			self.ship.receiveDamage()
			//TODO: send damage message to enemy player
			
		} else if (contactMask == (CollisionConstants.bulletCategoryMask | CollisionConstants.shipCategoryMask)) {
			let bullet: BulletNode?
			// next, sort out which body is the missile and which is the rocket
			// and do something about it
			if (contact.nodeA.physicsBody?.categoryBitMask == CollisionConstants.bulletCategoryMask) {
				bullet = contact.nodeA.parent as? BulletNode
			} else {
				bullet = contact.nodeB.parent as? BulletNode
			}
			removeNode(remove: bullet)
			self.ship.receiveDamage()
			
			//TODO: send file update message to enemy player
		}
	}
	
	func removeNode(remove: SCNNode?){
		if let node = remove {
			node.removeAllActions()
			node.removeFromParentNode()
		}
	}
}

