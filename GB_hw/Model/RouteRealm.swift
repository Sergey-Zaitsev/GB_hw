//
//  RouteRealm.swift
//  GB_hw
//
//  Created by Сергей Зайцев on 27.03.2022.
//

import RealmSwift
import UIKit
import CoreLocation

class RouteRealm: Object{
    dynamic var name = ""
    let locationArray = List<Coordinates>()
}

class Coordinates: Object {
    dynamic var long: Double = 0
    dynamic var lat: Double = 0
}
