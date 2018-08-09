//
//  GameConstants.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 06/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation

struct GameConstants {
	//MARK: Bullet constants
	static let bulletSpeed: Float = 10.0
	static let bulletDuration: Double = 6.0
	
	//MARK: Movement Constants
	static let speedFactor: Float = 1.0
	static let rotationFactor: Float = 4.0
	static let rotationMax = 0.5
	
	//MARK: Motion Detection Constantes
	static let phoneInitialInclination = 0.25
	static let motionUpdateInterval = 1/30.0

	//MARK: damage constants
	static let shipLife = 3
	static let immunityTime = 3.0
	
}
