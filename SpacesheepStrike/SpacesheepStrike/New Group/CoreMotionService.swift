//
//  CoreMotionService.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 06/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import CoreMotion

class CoreMotionService {
	
	static let shared = CoreMotionService()
	let motionManager = CMMotionManager()
	var deviceQuaternion: CMQuaternion?
	var attitude: CMAttitude?
	
	private init() {
		if motionManager.isDeviceMotionAvailable {
			motionManager.deviceMotionUpdateInterval = GameConstants.motionUpdateInterval
			motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: OperationQueue(), withHandler: { (deviceMotion, error) in
				guard let data = deviceMotion else { return }
				self.deviceQuaternion = data.attitude.quaternion
				self.attitude = data.attitude
			})
		}
	}
	
}
