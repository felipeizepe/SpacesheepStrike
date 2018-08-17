//
//  Spaceship.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 03/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import SceneKit

class Spaceship {
	var node: SCNNode!
	var shipMesh: SCNNode!
	var bodyNode: SCNNode!
	var currentDamage: Int!
	var scene: SCNScene!
	var camera: SCNNode!
	private var immune: Bool!
	
	//MARK: SoundEffect Nodes
	var fireSound: SCNAudioSource!
	var hitSound: SCNAudioSource!
	var shipVelocity: SCNVector3 = SCNVector3Make(0, 0, 5)
	
	//MARK: Lifecycle methos
	
	init(spaceshipNode: SCNNode, scene: SCNScene) {
		self.node = spaceshipNode
		self.scene = scene
		self.setupSpaceship()
	}
	
	//MARK: Auxiliary methods
	/// Sets up the spaceship initial values
	func setupSpaceship() {
		self.bodyNode = node.childNode(withName: "ship", recursively: true)
		
		if let thrusters = node.childNode(withName: "thrustersBox", recursively: true) {
			let smoke = Spaceship.createSmokeTrail(geometry: thrusters.geometry!)
			thrusters.addParticleSystem(smoke)
		}
		
		if let wingLeft = node.childNode(withName: "wingL", recursively: true) {
			let wind = Spaceship.createWindTrail(geometry: wingLeft.geometry!)
			wingLeft.addParticleSystem(wind)
		}
		
		if let wingRight = node.childNode(withName: "wingR", recursively: true) {
			let wind = Spaceship.createWindTrail(geometry: wingRight.geometry!)
			wingRight.addParticleSystem(wind)
		}
		
		if let ship = scene.rootNode.childNode(withName: "shipMesh", recursively: true) {
			self.shipMesh = ship
		}
		
		if let cm = scene.rootNode.childNode(withName: "camera", recursively: true) {
			self.camera = cm
			camera.constraints = [SCNLookAtConstraint.init(target: self.shipMesh)]
		}
		
		if let cameraNode = scene.rootNode.childNode(withName: "CameraRotationNode", recursively: true) {
			cameraNode.constraints = [SCNDistanceConstraint.init(target: self.shipMesh), SCNLookAtConstraint.init(target: self.shipMesh)]
		}
		
		self.currentDamage = 0
		self.immune = false
		
		//MARK: sound setup
		self.fireSound = SCNAudioSource(fileNamed: "art.scnassets/Sounds/LaserShot.wav")
		self.hitSound = SCNAudioSource(fileNamed: "art.scnassets/Sounds/Shields.wav")
		
		
	}
	
	
	/// Moves the ship in relation to a SCNQuaternion representing the devices rotational position
	///
	/// - Parameter quet: Quaternion value of the devices rotation
	func moveInRelation(toQuaternion quet: SCNQuaternion, pitch: Float, yaw: Float) {
		let simq = simd_quatf(quet)
		bodyNode.simdOrientation = simq * AnimationConstants.rotationAxis
		if let pbody = node.physicsBody {
//			let vel = SCNVector3Make(GameConstants.speedFactorX, GameConstants.speedFactorY, GameConstants.speedFactorZ)
//			let directionQuat = simq.act(simd_make_float3(vel.x, vel.y, vel.z))
//			let velocity = SCNVector3Make(directionQuat.x, directionQuat.y, abs(directionQuat.z))
			let direction = self.shipVelocity
			let yVector = SCNVector3Make(0, 1, 0)
			let rotDirection = direction.escalarProduct(escalar: cos(pitch)) +
				yVector.crossProduct(v: direction).escalarProduct(escalar: sin(pitch)) +
				yVector.escalarProduct(escalar: yVector.dotProduct(v: direction) * (1 - pitch))
			self.shipVelocity = rotDirection
			pbody.velocity = rotDirection
			
			self.bodyNode.position.y = self.bodyNode.presentation.position.y + yaw * 10
			self.shipMesh.eulerAngles.y = self.shipMesh.eulerAngles.y + pitch
			self.shipMesh.eulerAngles.z = pitch * 50
			let pos = self.bodyNode.presentation.position
			if pos.y > 100 {
				self.bodyNode.position.y = 100
			} else if pos.y < -100 {
				self.bodyNode.position.y = -100
			}
		}
	}
	
	
	
	/// Creates a projectile to fire
	///
	/// - Returns: Projectile etity of the ship
	func createProjectile() -> BulletNode? {
		if self.node.physicsBody != nil {
			if let bulletBody = SCNScene(named: "art.scnassets/bullet.scn")?.rootNode.childNode(withName: "bullet", recursively: true) {
				let bullet = BulletNode(bulletChild: bulletBody, owner: self)
				bulletBody.simdOrientation = bodyNode.simdOrientation
				bullet.position = self.node.presentation.position

				for childB in bulletBody.childNodes {
					if let bbody = childB.physicsBody {
//						bbody.velocity = SCNVector3Make(pbody.velocity.x, pbody.velocity.y, pbody.velocity.z + GameConstants.bulletSpeed)
						bbody.velocity = self.shipVelocity.escalarProduct(escalar: 10.0)
//						let sparks = BulletNode.createSparks(geometry: childB.geometry!)
//						childB.addParticleSystem(sparks)
					}
				}
				//Removes bullet from parent after certain time
				bullet.runAction(SCNAction.sequence([SCNAction.wait(duration: GameConstants.bulletDuration), SCNAction.removeFromParentNode()]))
				self.node.runAction(SCNAction.playAudio(fireSound, waitForCompletion: false))
				return bullet
				
				}
				
		}
		
		return nil
	}
	
	
	/// Receive damage and checks if the game is over, if not makes the ship immune to damage for a certain time
	func receiveDamage(){
		if immune {
			return
		}
		
		self.currentDamage = self.currentDamage! + 1
		
		self.node.runAction(SCNAction.playAudio(hitSound, waitForCompletion: false))
		
		if currentDamage >= GameConstants.shipLife  {
			//GAME OVER
			print("Game Over")
			//TODO: Game Over state change
		}else {
			immune = true
			DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.immunityTime, execute: {
				self.immune = false
			})
		}
	}
	
	
	static func createSmokeTrail(geometry: SCNGeometry) -> SCNParticleSystem {
		let trail = SCNParticleSystem(named: "smokeTrail.scnp", inDirectory: nil)!
		trail.emitterShape = geometry
		return trail
	}
	
	static func createWindTrail(geometry: SCNGeometry) -> SCNParticleSystem {
		let trail = SCNParticleSystem(named: "WindParticle.scnp", inDirectory: nil)!
		trail.emitterShape = geometry
		return trail
	}
}

extension SCNVector3 {
	func crossProduct(v: SCNVector3) -> SCNVector3 {
		let vector = SCNVector3Make(self.y * v.z - self.z * v.y,
									self.z * v.x - self.x * v.z,
									self.x * v.y - self.y * v.x)
		return vector
	}
	
	func dotProduct(v: SCNVector3) -> Float {
		return (self.x * v.x) + (self.y * v.y) + (self.z * v.z)
	}
	
	func escalarProduct(escalar: Float) -> SCNVector3 {
		let vector = SCNVector3Make(self.x * escalar,
									self.y * escalar,
									self.z * escalar)
		return vector
	}
	
	static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
		return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
	}
}
















