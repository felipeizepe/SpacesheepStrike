//
//  StartScene.swift
//  SpacesheepStrike
//
//  Created by Richard Vaz da Silva Netto on 13/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import SceneKit

class StartScene: SCNScene {
	var scene: SCNScene?
	
	override init() {
		super.init()
		guard let scene = SCNScene(named: "StartScene.scn") else {
			print("ERROR: Scene Not Found")
			return
		}
		self.scene = scene
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
