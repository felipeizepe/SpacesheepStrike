//
//  SKCheckBoxButton.swift
//  SpacesheepStrike
//
//  Created by Richard Vaz da Silva Netto on 13/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import SpriteKit

class SKCheckBoxButton: SKSpriteNode {
	var checkedBox: SKSpriteNode? {
		if let node = self.childNode(withName: "CheckedBox") as? SKSpriteNode {
			return node
		}
		return nil
	}
	
	/// Function that togles the checkBox
	///
	/// - Parameters:
	///
	func pressed(actionAfterAnimation: SKAction) {
		// Button animation
		let fadeOutAction = SKAction.fadeOut(withDuration: 0.1)
		let fadeInAction = fadeOutAction.reversed()
		let actionSequence = SKAction.sequence([fadeOutAction,fadeInAction,actionAfterAnimation])
		self.run(actionSequence)
		
		// Toggle check box
		guard (checkedBox != nil) else {
			print("ERROR: No checkBox found in SKSpriteNode")
			return
		}
		if (self.checkedBox?.isHidden)! {
			checkedBox?.isHidden = false
		}else {
			checkedBox?.isHidden = true
		}
		
		print("\(self.name!) pressed.")
	}
}
