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
	
	func setupSpaceship() {
		self.bodyNode = node.childNode(withName: "ship", recursively: true)
	}
	
	func moveInRelation(toPoint point: SCNVector3, factor: Float) {
		let quet = simd_quatf(SCNQuaternion(-point.y, 0,point.x,factor))
		bodyNode.simdOrientation = quet * AnimationConstants.rotationAxis 
		
		if let pbody = node.physicsBody {
			let direction = SCNVector3Make( -point.x * GameConstants.speedFactor, point.y * GameConstants.speedFactor, 0.3 - 0.3 * (point.y - point.x))
			pbody.velocity = direction
		}
		
	}
	
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
