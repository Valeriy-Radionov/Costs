//
//  Limit.swift
//  Costs
//
//  Created by Valera on 9.06.21.
//  Copyright © 2021 Valera. All rights reserved.
//

import RealmSwift

class Limit: Object {
    
    @objc dynamic var limitSum = ""
    @objc dynamic var limitDate = NSDate()
    @objc dynamic var limitLastDay = NSDate()
}
