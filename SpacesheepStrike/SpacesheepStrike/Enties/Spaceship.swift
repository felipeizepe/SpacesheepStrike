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
	//MARK: Lifecycle methos
	
	 init(spaceshipNode: SCNNode) {
		self.node = spaceshipNode
		self.setupSpaceship()
		
	}
	
	//MARK: Auxiliary methods
	
	
	/// Sets up the spaceship initial values
	func setupSpaceship() {
		self.bodyNode = node.childNode(withName: "ship", recursively: true)
	}
	
	
	/// Moves the ship in relation to a SCNQuaternion representing the devices rotational position
	///
	/// - Parameter quet: Quaternion value of the devices rotation
	func moveInRelation(toQuaternion quet: SCNQuaternion) {
		let simq = simd_quatf(quet)
		bodyNode.simdOrientation = simq * AnimationConstants.rotationAxis
		if let pbody = node.physicsBody {
			//let direction = SCNVector3Make( -quet.z * GameConstants.speedFactor, -quet.x * GameConstants.speedFactor, 0.3 - 0.6 * (quet.z - quet.x))
			let direct = simd_make_float4(pbody.velocity.x,pbody.velocity.y,pbody.velocity.z,0)
			let rotatedVelocity = simd_mul(bodyNode.simdTransform, direct)
			let vectorVelocity = SCNVector3(x: rotatedVelocity.y, y: rotatedVelocity.x, z: rotatedVelocity.z)
			pbody.velocity = vectorVelocity
		}
		
	}
	
	
	/// Creates a projectile to fire
	///
	/// - Returns: Projectile etity of the ship
	func createProjectile() -> SCNNode? {
		if let pbody = self.node.physicsBody {
			if let bullet = SCNScene(named: "art.scnassets/bullet.scn")?.rootNode.childNode(withName: "bullet", recursively: true) {
				if let bbody = bullet.physicsBody {
					bbody.velocity = SCNVector3Make(pbody.velocity.x, pbody.velocity.y, pbody.velocity.z + GameConstants.bulletSpeed)
					return bullet
				}
			}
		}
		
		return nil
	}
}
