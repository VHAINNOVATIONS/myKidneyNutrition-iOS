//
//  FoodItem.swift
//  VAKidneyNutrition
//
//  Created by TCCODER on 2/23/18.
//  Modified by TCCODER on 03/04/18.
//  Copyright © 2018 Topcoder. All rights reserved.
//

import SwiftyJSON

/// Possible Food Item types
enum FoodItemType: String {
    case food = "food", drug = "drug"
}

/**
 * Food Intake item model object
 *
 * - author: TCCODER
 * - version: 1.1
 *
 * changes:
 * 1.1:
 * - Integration changes
 */
public class FoodItem: CacheableObject {

    /// the fields
    var title = ""
    var units = ""
    var amount: Float = 0
    var type: FoodItemType = .food

    /// Parse JSON to model object
    ///
    /// - Parameter json: JSON
    /// - Returns: the object
    class func fromJson(_ json: JSON) -> FoodItem {
        let object = FoodItem(id: json["id"].stringValue)
        object.title = json["items"].stringValue
        object.units = json["units"].stringValue
        object.amount = json["amount"].floatValue
        return object
    }

    /// Clone object
    ///
    /// - Returns: the cloned instance
    func clone() -> FoodItem {
        let object = FoodItem(id: id)
        object.deletedLocally = deletedLocally
        object.managedObjectID = managedObjectID
        object.retrievalDate = retrievalDate

        object.title = title
        object.units = units
        object.amount = amount
        object.type = type
        return object
    }
}

