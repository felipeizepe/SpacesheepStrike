//
//  CreateRoomViewController.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 17/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import UIKit

class CreateRoomViewController: UIViewController {
	
	// MARK: Outlets
	@IBOutlet weak var nameLabel: UITextField!
	
	// MARK: Lifecycle Methods
	override func viewDidLoad() {
		let tap = UITapGestureRecognizer(target: nil, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false
		self.view.addGestureRecognizer(tap)
	}
	
	
	// MARK: Auxiliary functions
	@objc func dismissKeyboard() {
		self.view.endEditing(true)
	}
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	@IBAction func createRoom(_ sender: Any) {
		self.generateRoom()
	}
	
	private func generateRoom() {
		guard let text = nameLabel.text, !text.isEmpty else {
			return
		}
		
		ConnectionHostService.shared.createRoom(named: text)
		
		if let room = ConnectionHostService.shared.room {
			performSegue(withIdentifier: "roomCreatedSegue", sender: room)
		}
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "roomCreatedSegue" {
			if let room = sender as? Room {
				if let view = segue.destination as? RoomViewController {
					view.room = room
				}
			}
		}
	}
}




