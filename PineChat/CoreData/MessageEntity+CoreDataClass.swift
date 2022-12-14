//
//  MessageEntity+CoreDataClass.swift
//  
//
//  Created by Ruslan Iskhakov on 16.11.2022.
//
//

import Foundation
import CoreData

@objc(MessageEntity)
public class MessageEntity: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        self.date = Date()
    }

    public var string: String {
        return "UUID: \(self.id?.uuidString), date: \(self.date), from: \(self.userName), text: \(self.text)"
    }

    public func toPersistantMessage() -> PersistantChatMessage {
        return PersistantChatMessage(
            id: self.id?.uuidString ?? "",
            date: self.date,
            userName: self.userName ?? "",
            text: self.text ?? "")
    }
}
