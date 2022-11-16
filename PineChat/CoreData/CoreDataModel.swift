//
//  CoreDataModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 16.11.2022.
//

import Foundation
import CoreData

class CoreDataModel {

    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PineChat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        })
        return container
    }()

    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    init() {

    }

    func putMessage(from: String, text: String, id: String) {
        var message = MessageEntity(context: self.context)
        message.userName = from
        message.text = text
        message.id = UUID(uuidString: id)

        self.saveContext()
    }

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func getAllMessages() {
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        if let messages = try? context.fetch(fetchRequest) {
            messages.forEach{print("Message: \($0.string)")}
        }
    }

    func getAllMessagesSortedById() {
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        if let messages = try? context.fetch(fetchRequest) {
            messages.forEach{print("Message: \($0.string)")}
        }
    }

    func getAllMessagesSortedByDate(limit: Int? = nil) {
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        if let limit {
            fetchRequest.fetchLimit = limit
        }
        if let messages = try? context.fetch(fetchRequest) {
            messages.forEach{print("Message: \($0.string)")}
        }
    }

//    func getLatestMessage() -> MessageEntity {
//        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
//        var predicate = NSPredicate(format: "date > %@", Date().)
//        fetchRequest.predicate = predicate
//        if let messages = try? context.fetch(fetchRequest) {
//            messages.forEach{print("Message: \($0.string)")}
//        }
//    }
}
