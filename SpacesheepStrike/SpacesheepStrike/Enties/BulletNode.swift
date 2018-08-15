//
//  BulletNode.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 09/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import SceneKit

class BulletNode: SCNNode {
	
	var owner: Spaceship!
	
	/// Initilizer for the bullet parent node
	///
	/// - Parameters:
	///   - bulletChild: bullet child
	///   - owner: ship that fired the bullet
	init(bulletChild: SCNNode, owner: Spaceship) {
		super.init()
		self.addChildNode(bulletChild)
		self.owner = owner
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	static func createSparks(geometry: SCNGeometry) -> SCNParticleSystem {
		let trail = SCNParticleSystem(named: "LaserSparks.scnp", inDirectory: nil)!
		trail.emitterShape = geometry
		return trail
	}
	
}
