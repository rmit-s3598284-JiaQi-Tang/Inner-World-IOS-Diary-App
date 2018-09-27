//
//  Diary+CoreDataProperties.swift
//  InnerWorld
//
//  Created by Linh Nguyen on 27/9/18.
//  Copyright © 2018 Linh Nguyen. All rights reserved.
//
//

import Foundation
import CoreData


extension Diary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Diary> {
        return NSFetchRequest<Diary>(entityName: "Diary")
    }

    @NSManaged public var id: Int16
    @NSManaged public var title: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var mood: String?
    @NSManaged public var weather: String?
    @NSManaged public var location: String?
    @NSManaged public var photo: String?
    @NSManaged public var content: String?

}
