//
//  RoomViewController.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 17/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import UIKit

class RoomViewController: UIViewController {
	
	@IBOutlet weak var playerTableView: UITableView!
	@IBOutlet weak var startButton: UIButton!
	
	// MARK: Properties
	
	var room: Room!
	var devices: [String] = [String]()
	
	
	// MARK: Lifecycle Methods
	override func viewDidLoad() {
		
		self.playerTableView.delegate = self
		self.playerTableView.dataSource = self
		
		if let selectedRoom = room {
			selectedRoom.service.roomStateDelegate = self
			self.devices = selectedRoom.service.getPlayersList()
			
			DispatchQueue.main.async {
				self.playerTableView.reloadData()
			}
			
		}
		
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "gameStartSegue" {
			if let gameView = segue.destination as? GameViewController {
				gameView.multipeerConnectivityService = self.room.service
			}
		}
	}
	
	// MARK: Action Outlets
	
	@IBAction func startGame(_ sender: Any) {
			self.startButton.isEnabled = false
			self.room.service.startGame()
	}
	
	private func launchGame() {
		DispatchQueue.main.async {
			self.startButton.isEnabled = false
			self.performSegue(withIdentifier: "gameStartSegue", sender: nil)
		}
	}
	
}

// MARK: Extension rooom state delegate
extension RoomViewController: RoomStateDelegate {
	func startGame() {
		self.launchGame()
	}
	
	func roomStateChanged(connectedDevices: [String]) {
		self.devices = connectedDevices
		DispatchQueue.main.async {
			self.playerTableView.reloadData()
		}
	}
}


extension RoomViewController: UITableViewDelegate {
	
}

extension RoomViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.devices.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as! RoomViewCell
		
		cell.setupPlayer(playerName: devices[indexPath.row])
		
		return cell
		
	}
	
}


