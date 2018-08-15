//
//  LobbyOverlay.swift
//  SpacesheepStrike
//
//  Created by Richard Vaz da Silva Netto on 14/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import SpriteKit

//protocol MultipeerConnectivityServiceProtocol {
//	func
//}

class LobbyOverlay: BaseOverlay {
//	var roomName: String?
	
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
		//Create an action to run after the button animation
		print("Open the keyboard to enter de room name, and open the browsing of the room")
	}
	
	func findRoom() {
		print("Open the availiable rooms")
	}
	
}

//extension LobbyOverlay: KeyboardResponseProtocol {
//	func textFieldValue(text: String) {
////		self.roomName = text
//	}
//}
