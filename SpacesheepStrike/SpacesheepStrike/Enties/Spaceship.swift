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
		
		self.currentDamage = 0
		self.immune = false
		
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
			let direction = SCNVector3Make( -quet.z * GameConstants.speedFactorX, -quet.x * GameConstants.speedFactorY, 0)
//			let direct = simd_make_float4(pbody.velocity.x,pbody.velocity.y,pbody.velocity.z,0)
//			let rotatedVelocity = simd_mul(bodyNode.simdTransform, direct)
//			let vectorVelocity = SCNVector3(x: rotatedVelocity.y, y: rotatedVelocity.x, z: rotatedVelocity.z)
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
		
		self.currentDamage += 1
		
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
}
