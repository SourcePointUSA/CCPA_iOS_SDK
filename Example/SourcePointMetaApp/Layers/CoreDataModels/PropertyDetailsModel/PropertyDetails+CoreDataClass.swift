//
//  PropertyDetails+CoreDataClass.swift
//  
//
//  Created by Vilas on 12/24/19.
//
//

import Foundation
import CoreData

@objc(PropertyDetails)
public class PropertyDetails: NSManagedObject {
    class var entityName : String {
        return "PropertyDetails"
    }
}
