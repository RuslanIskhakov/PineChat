//
//  MessageEntity+CoreDataProperties.swift
//  
//
//  Created by Ruslan Iskhakov on 16.11.2022.
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var userName: String?
    @NSManaged public var text: String?

}
