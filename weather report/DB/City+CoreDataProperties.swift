//
//  City+CoreDataProperties.swift
//  weather report
//
//  Created by alex surmava on 04.02.25.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var name: String?

}

extension City : Identifiable {

}
