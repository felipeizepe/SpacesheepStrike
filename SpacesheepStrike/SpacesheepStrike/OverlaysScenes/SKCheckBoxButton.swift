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
	func pressed() {
		print("\(self.name!) pressed.")
		guard (checkedBox != nil) else {
			print("ERROR: No checkBox found in SKSpriteNode")
			return
		}
		if (self.checkedBox?.isHidden)! {
			checkedBox?.isHidden = false
		}else {
			checkedBox?.isHidden = true
		}
	}
}
