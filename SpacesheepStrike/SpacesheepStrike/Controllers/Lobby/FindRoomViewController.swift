//
//  FindRoomViewController.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 16/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import UIKit


class FindRoomViewController: UIViewController {
	
	// MARK: Outlets
	@IBOutlet weak var roomsTableView: UITableView!
	
	// MARK: Properties
	var receivedRooms: [Room] = [Room]()
	
	// MARK: Lifecycle Methods
	
	override func viewDidLoad() {
		self.setupScroll()
	}
	
	// MARK: Auxiliary Methods
	
	func setupScroll() {
		roomsTableView.delegate = self
		roomsTableView.dataSource = self
		ConnectionUserService.shared.startSearch()
		print("HI")
	}
	
}

// MARK: Room search delegate extension

extension FindRoomViewController: RoomsSearchDelegate {
	func updateRooms(rooms: [Room]) {
		DispatchQueue.main.async {
			self.receivedRooms = rooms
			self.roomsTableView.reloadData()
		}
	}
}

// MARK: Table View Delegate Extension

extension FindRoomViewController: UITableViewDelegate {

}

// MARK: Table View Data Source Extension

extension FindRoomViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.receivedRooms.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as! RoomViewCell
		
		cell.setupRoom(cellRoom: receivedRooms[indexPath.row])
		
		return cell
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// TODO: Connect to room
		ConnectionUserService.shared.stopSearch()
	}
	
}
