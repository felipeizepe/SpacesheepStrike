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
	
	var multipeerConnectivityService: ConnectionService?
	var enemy: SCNNode!
	var ship: Spaceship!
	var shipMesh: SCNNode?
	
	var pitch: Float? = 0
	var roll: Float? = 0
	var initialOrientation: (pitch: Float,roll: Float)?
	
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
		// Get the node that represent the player
		if let shipMesh = scene.rootNode.childNode(withName: "shipMesh", recursively: true) {
			self.shipMesh = shipMesh
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
		scnView.debugOptions = [SCNDebugOptions.showPhysicsShapes]
		
		// show statistics such as fps and timing information
		scnView.showsStatistics = true
		
		// add a tap gesture recognizer
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		scnView.addGestureRecognizer(tapGesture)
		
		// configure the view
		scnView.backgroundColor = UIColor.white
		
//		self.setupSound()
		
		if let service = multipeerConnectivityService {
			service.gameDataDelegate = self
		}
	}
	
	//MARK: Outlets methods
	@objc
	func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		//Get the device initial position
		self.resetOrientation()
	}
	
	/// Start the services needed
	func setupServices() {
		self.multipeerConnectivityService?.gameDataDelegate = self
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
			//Get the device initial position
			if initialOrientation == nil {
				self.resetOrientation()
			}
			ship.moveInRelation(toQuaternion: scnQuaterion, pitch: (self.pitch! - (initialOrientation?.pitch)!) / 10.0, yaw: (self.roll! - (initialOrientation?.roll)!) / 2)
		}
		
		//Send information to opponent
		if let att = CoreMotionService.shared.attitude {
//			//self.multipeerConnectivityService.send(motion: att)
			self.pitch = Float(att.pitch / 10)
			self.roll = Float(att.roll)
			multipeerConnectivityService?.send(myNode: (self.shipMesh?.presentation)!)
		}
	}
}

extension GameViewController: GameDataDelegate {
	func motionChanged(myNode: SCNNode?) {
		
	}
	
	func receiveMotion(enemyNode: SCNNode?) {
		if let enemyNode = enemyNode {
			print(enemy.presentation.position)
			enemy.position = enemyNode.position
			enemy.eulerAngles = enemyNode.eulerAngles
//			enemy.orientation = enemyNode.orientation
		}
	}
	
	func connectedDevicesChanged( connectedDevices: [String]) {
		OperationQueue.main.addOperation {
			self.sessionOwnerLabel.text = "Connections: \(connectedDevices)"
		}
	}
	
	func resetOrientation() {
		if let att = CoreMotionService.shared.attitude {
			self.initialOrientation = (Float(att.pitch / 10), Float(att.roll))
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

