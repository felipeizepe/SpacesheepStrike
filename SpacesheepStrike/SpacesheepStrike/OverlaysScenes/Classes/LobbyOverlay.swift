//
//  LobbyOverlay.swift
//  SpacesheepStrike
//
//  Created by Richard Vaz da Silva Netto on 14/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import SpriteKit

class LobbyOverlay: BaseOverlay {
	
	override func checkedButtonPressed(button: SKCheckBoxButton) {
		let action = SKAction.run {
			print("LobbyOverlay - Checked Button Pressed")
		}
		button.pressed(actionAfterAnimation: action)
	}
	
	override func buttonPressed(button: SKButton) {
//		let action = SKAction.run {
//			print("LobbyOverlay - Button Pressed")
//		}
//		button.pressed(actionAfterAnimation: action)
		switch button.name {
		case "CreateRoomButton":
			createRoom()
		case "FindRoomButton":
			findRoom()
		default:
			print("Default Button")
		}
	}
	
	override func changeOverlay() {
		self.overlayDelegate?.setHUDLoadingOverlay()
	}
	
	func createRoom() {
		
	}
	
	func findRoom() {
		
	}
}
