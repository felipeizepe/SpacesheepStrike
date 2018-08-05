//
//  CoreDataServices.swift
//  ShipSensorMovementStream
//
//  Created by Richard Vaz da Silva Netto on 31/07/18.
//  Copyright © 2018 Richard Vaz da Silva Netto. All rights reserved.
//

import Foundation
import CoreMotion

protocol CoreMotionServiceDelegate {
	func sendMotionData(deviceMotion: CMDeviceMotion)
}

class CoreMotionService: NSObject {
	public var motionManager: CMMotionManager?
	private var motionHandler: CMDeviceMotionHandler?
	public var delegate: CoreMotionServiceDelegate?
	
	override init() {
		super.init()
		setupManager()
		setupDeviceMotion()
	}
	
	private func setupManager() {
		motionManager = CMMotionManager()
	}
	
	private func setupDeviceMotion() {
		// TODO: - Check if the update interval will result in lag of late uptates, maybe
		// TODO: it should be initiallized another way
		motionManager?.deviceMotionUpdateInterval = 2.0 / 60.0
		// Motion Handler
		motionHandler = { deviceMotion, error in
			guard (error == nil) else {
				print("Error in device motion update: \(String(describing: error))")
				return
			}
			self.delegate?.sendMotionData(deviceMotion: deviceMotion!)
			return
		}
		// TODO: - Maybe the Operation Queue should be diferent from others, and handler
		// TODO: should send the message to the sessions
		motionManager?.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: motionHandler!)
	}
}
