//
//  CoreDataModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import RxSwift

protocol CoreDataModelProtocol {
    var appModel: AppModelProtocol? {get set}
    var newChatMessagePosted: PublishSubject<Void> {get}
    func getLastMessageId() -> String
    func getMessages(from id: String, ahead: Bool, limit: Int) -> [PersistantChatMessage]
    func putNewMessage(_ message: PostNewChatMessage)
}
