//
//  CoreDataModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 16.11.2022.
//

import Foundation
import CoreData

class CoreDataModel: BaseModelInitialisable, CoreDataModelProtocol {

    weak var appModel: AppModelProtocol?

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PineChat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private lazy var context: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()

    func getLastMessageId() -> String {
        return self.getAllMessagesSortedByDate(limit: 1).first?.id ?? ""
    }

    func putNewMessage(_ message: PostNewChatMessage) {
        self.context.perform {
            let cdMessage = MessageEntity(context: self.context)
            cdMessage.userName = message.userName
            cdMessage.text = message.message
            cdMessage.id = UUID()

            self.saveContext()
        }
    }
}

private extension CoreDataModel {

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

    func getAllMessages() -> [PersistantChatMessage] {
        var result = [PersistantChatMessage]()

        self.context.performAndWait{
            let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
            if let messages = try? context.fetch(fetchRequest) {
                result.append(contentsOf: messages.map{$0.toPersistantMessage()})
            }
        }
        return result
    }

    func getAllMessagesSortedById() -> [PersistantChatMessage] {
        var result = [PersistantChatMessage]()

        self.context.performAndWait{
            let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
            let sort = NSSortDescriptor(key: "id", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            if let messages = try? context.fetch(fetchRequest) {
                result.append(contentsOf: messages.map{$0.toPersistantMessage()})
            }
        }
        return result
    }

    private func getAllMessagesSortedByDate(limit: Int? = nil, ascending: Bool = true) -> [PersistantChatMessage]{

        var result = [PersistantChatMessage]()

        self.context.performAndWait{
            let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
            let sort = NSSortDescriptor(key: "date", ascending: ascending)
            fetchRequest.sortDescriptors = [sort]
            if let limit {
                fetchRequest.fetchLimit = limit
            }
            if let messages = try? context.fetch(fetchRequest) {
                result.append(contentsOf: messages.map{$0.toPersistantMessage()})
            }
        }

        return result
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
