//
//  MenuViewController.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 16/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UIViewController {
	
	
	@IBAction func findRoomAction(_ sender: Any) {
		performSegue(withIdentifier: "searchSegue", sender: nil)
	}
	
	@IBAction func createRoomAction(_ sender: Any) {
		performSegue(withIdentifier: "createSegue", sender: nil)
	}
	
}
