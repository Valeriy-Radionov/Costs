//
//  SpendingModel.swift
//  Costs
//
//  Created by Valera on 4.06.21.
//  Copyright © 2021 Valera. All rights reserved.
//

import RealmSwift

class Spending: Object {
    
    @objc dynamic var category: String = ""
    @objc dynamic var cost: Int = 1
    @objc dynamic var data: NSDate = NSDate()
}
