//
//  DoubleExtensions.swift
//  SpacesheepStrike
//
//  Created by Felipe Izepe on 08/08/18.
//  Copyright © 2018 Felipe Izepe. All rights reserved.
//

import Foundation

extension Double {
	func format(f: String) -> String {
		return String(format: "%\(f)f", self)
	}
}
