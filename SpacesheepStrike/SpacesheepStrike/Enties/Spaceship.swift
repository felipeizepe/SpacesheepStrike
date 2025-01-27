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
	var bodyNode: SCNNode!
	var currentDamage: Int!
	private var immune: Bool!
	private(set) var dead = false
	
	//MARK: SoundEffect Nodes
	var fireSound: SCNAudioSource!
	var hitSound: SCNAudioSource!
	
	//MARK: Lifecycle methos
	
	 init(spaceshipNode: SCNNode) {
		self.node = spaceshipNode
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
		
		
		self.currentDamage = 0
		self.immune = false
		self.dead = false
		
		//MARK: sound setup
		self.fireSound = SCNAudioSource(fileNamed: "art.scnassets/Sounds/LaserShot.wav")
		self.hitSound = SCNAudioSource(fileNamed: "art.scnassets/Sounds/Shields.wav")
		
		
	}
	
	
	/// Moves the ship in relation to a SCNQuaternion representing the devices rotational position
	///
	/// - Parameter quet: Quaternion value of the devices rotation
	func moveInRelation(toQuaternion quet: SCNQuaternion) {
		let simq = simd_quatf(quet)
		bodyNode.simdOrientation = simq * AnimationConstants.rotationAxis
		if let pbody = node.physicsBody {
//			let vel = SCNVector3Make(GameConstants.speedFactorX, GameConstants.speedFactorY, GameConstants.speedFactorZ)
//			let directionQuat = simq.act(simd_make_float3(vel.x, vel.y, vel.z))
//			let velocity = SCNVector3Make(directionQuat.x, directionQuat.y, abs(directionQuat.z))
			let direction = SCNVector3Make( -quet.z * GameConstants.speedFactorX, -quet.x * GameConstants.speedFactorY,0)
			pbody.velocity = direction
		}
	}
	
	/// Creates a projectile to fire
	///
	/// - Returns: Projectile etity of the ship
	func createProjectile() -> BulletNode? {
		if let pbody = self.node.physicsBody {
			if let bulletBody = SCNScene(named: "art.scnassets/bullet.scn")?.rootNode.childNode(withName: "bullet", recursively: true) {
				let bullet = BulletNode(bulletChild: bulletBody, owner: self)
				bulletBody.simdOrientation = bodyNode.simdOrientation
				bullet.position = self.node.presentation.position

				for childB in bulletBody.childNodes {
					if let bbody = childB.physicsBody {
						bbody.velocity = SCNVector3Make(pbody.velocity.x, pbody.velocity.y, pbody.velocity.z + GameConstants.bulletSpeed)
						let sparks = BulletNode.createSparks(geometry: childB.geometry!)
						childB.addParticleSystem(sparks)
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
			self.dead = true
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
