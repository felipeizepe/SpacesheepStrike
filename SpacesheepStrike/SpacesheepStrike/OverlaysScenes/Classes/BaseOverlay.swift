//
//  BaseOverlay.swift
//  SpacesheepStrike
//
//  Created by Richard Vaz da Silva Netto on 13/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import SpriteKit

protocol OverlayProtocol {
	func setStartOverlay()
	func setLobbyOverlay()
	func setHUDLoadingOverlay()
	func setHUDOverlay()
	func setEndGameOverlay()
}

class BaseOverlay: SKScene {
	public var overlayDelegate: OverlayProtocol?
	
	func tapReceived(location: CGPoint){
		let convertedLocation = self.convertPoint(fromView: location)
		let nodesPressed = self.nodes(at: convertedLocation)
		for node in nodesPressed {
			if let button = node as? SKCheckBoxButton {
				self.checkedButtonPressed(button: button)
			} else if let button = node as? SKButton {
				self.buttonPressed(button: button)
			}
		}
	}
	
	func checkedButtonPressed(button: SKCheckBoxButton) {
	}
	
	func buttonPressed(button: SKButton) {
	}
	
	func changeOverlay() {
	}
}
