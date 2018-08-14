//
//  SKButton.swift
//  SpacesheepStrike
//
//  Created by Richard Vaz da Silva Netto on 13/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import SpriteKit

class SKButton: SKSpriteNode {
	/// Function called to inform that the button is pressed
	///
	/// - Parameters:
	///
	func pressed(){
		print("\(self.name!) pressed.")
	}
}
