//
//  EndGameOverlay.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 20/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import SpriteKit

class EndGameOverlay: BaseOverlay {
	
	override func buttonPressed(button: SKButton) {
		if let gameView = self.view {
			let lobbyStoryboard = UIStoryboard(name: TransitionConstants.lobbyStoryboardName, bundle: nil)
			guard let lobby = lobbyStoryboard.instantiateViewController(withIdentifier: TransitionConstants.menuViewControllerID) as? MenuViewController else {
				return
			}
			gameView.window?.rootViewController?.show(lobby, sender: nil)
			
		}
	}
	
	func setupLabels(winner: String, looser: String) {
		
		self.enumerateChildNodes(withName: "WinnerNameLabel") { (node: SKNode, nil) in
			let label = node as! SKLabelNode
			label.text = winner
		}
		
		self.enumerateChildNodes(withName: "LostNameLabel") { (node: SKNode, nil) in
			let label = node as! SKLabelNode
			label.text = looser
		}
		
		let button = self.childNode(withName: "LeaveButton") as! SKSpriteNode
		button.isUserInteractionEnabled = true
		
	}
	
}
