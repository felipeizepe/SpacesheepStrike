//
//  ScenarioService.swift
//  SpacesheepStrike
//
//  Created by Richard Vaz da Silva Netto on 06/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import SceneKit

class ScenarioService: NSObject {
	private var treePercentage: Float = 0.1
	private var rockPercentage: Float = 0.01
	
	override init() {
		super.init()
	}
	
	public func generateScenario(scene: SCNScene, row: Int, column: Int) {
		for i in -row...row {
			for j in -column...column {
				if let node = getRandomScenarioNode() {
					node.position.x = Float(i*30)
					node.position.z = Float(j*30)
					node.position.y = -10
					scene.rootNode.addChildNode(node)
				}
			}
		}
	}
	
	private func getRandomScenarioNode() -> SCNNode? {
		let nodeSelected: Float = Float(arc4random_uniform(101))/Float(100)
		
		if nodeSelected < rockPercentage {
			let rockNumber = arc4random_uniform(29) + 1 // From 1 to 29
			let rockScene: SCNScene = SCNScene(named: "art.scnassets/Rocks/Rock\(rockNumber).dae")!
			let rockNode: SCNNode = rockScene.rootNode.childNode(withName: "Rock_\(rockNumber)", recursively: true)!
			return rockNode
		}else if nodeSelected < rockPercentage + treePercentage {
			let treeNumber = arc4random_uniform(6) + 7 // From 1 to 12
			let treeScene: SCNScene = SCNScene(named: "art.scnassets/Trees/Tree\(treeNumber).dae")!
			let treeNode: SCNNode = treeScene.rootNode.childNode(withName: "Tree\(treeNumber)", recursively: true)!
			return treeNode
		}else{
			return nil
		}
		
	}
}
