//
//  Spaceship.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 03/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import SceneKit

class Spaceship: SCNNode {
	
	
	//MARK: Lifecycle methos
	
	override init() {
		super.init()
		self.setupSpaceship()
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setupSpaceship()
	}
	
	//MARK: Auxiliary methods
	
	func setupSpaceship(){
		let force = SCNVector3(0.0, 0.0, 10.0)
		self.physicsBody?.applyForce(force, asImpulse: false)
	}
	
}
