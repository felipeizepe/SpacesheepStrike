//
//  QuaternionExtension.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 07/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation
import SceneKit
import CoreMotion

extension simd_quatf {
	init(_ cmq: SCNQuaternion) {
		self.init(ix: Float(cmq.x), iy: Float(cmq.y), iz: Float(cmq.z), r: Float(cmq.w))
	}
}

extension CMQuaternion {
	mutating func restrict(restrictionValue value: Double) {
		
		self.y = retrictedValue(value: self.y, max: value)
		self.x = retrictedValue(value: self.x, max: value)
		self.z = retrictedValue(value: self.z, max: value)
		self.w = retrictedValue(value: self.w, max: value)
		
	}
	
	fileprivate func retrictedValue(value: Double, max: Double) -> Double {
		let negative = (-1) * max
		if value > max {
			return max
		}else if self.y < negative {
			return negative
		}
		
		return value
	}
	
}
