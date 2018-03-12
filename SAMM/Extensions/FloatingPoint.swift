//
//  FloatingPoint.swift
//  SAMM
//
//  Created by Eleazer Arcilla on 12/03/2018.
//  Copyright © 2018 Eleazer Arcilla. All rights reserved.
//

import Foundation
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
