//
//  Item+CoreDataProperties.swift
//
//
//  Created by cwr on 2023/6/29.
//
//  This file was automatically generated and should not be edited.
//

import CoreData
import Foundation

public extension Item {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Item> {
        NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged var timestamp: Date?
}

extension Item: Identifiable {}
