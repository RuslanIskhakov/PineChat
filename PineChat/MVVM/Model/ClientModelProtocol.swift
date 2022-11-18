//
//  ClientModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import RxSwift

protocol ClientModelProtocol {
    var appModel: AppModelProtocol? {get set}
    var chatMessagesFromServer: PublishSubject<ChatMessagesResponse> {get}
    func startClient()
    func stopClient()
    func postChatMessage(_ text: String)
}
