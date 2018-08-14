//
//  StartOverlay.swift
//  SpacesheepStrike
//
//  Created by Richard Vaz da Silva Netto on 13/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import SpriteKit

class StartOverlay: BaseOverlay {
	override func checkedButtonPressed(button: SKCheckBoxButton) {
		let action = SKAction.run {
			self.changeSound()
			print("StartOverlay - Checked Button Pressed")
		}
		button.pressed(actionAfterAnimation: action)
	}
	
	override func buttonPressed(button: SKButton) {
		let action = SKAction.run {
			self.changeOverlay()
			print("StartOverlay - Button Pressed")
		}
		button.pressed(actionAfterAnimation: action)
	}
	
	override func changeOverlay() {
		self.overlayDelegate?.setLobbyOverlay()
	}
	
	func changeSound() {
		print("Sound Changed")
	}
}

