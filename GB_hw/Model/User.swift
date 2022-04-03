//
//  User.swift
//  GB_hw
//
//  Created by Сергей Зайцев on 27.03.2022.
//

import UIKit
import RealmSwift

class User: Object{
    @objc dynamic var login: String = ""
    @objc dynamic var passsword: String = ""
    
    override static func primaryKey() -> String? {
        return "login"
    }
}
