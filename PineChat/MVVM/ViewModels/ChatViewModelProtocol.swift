//
//  ChatViewModelProtocol.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import RxSwift
import RxRelay

enum ChatViewStateEvent {
    case idle
    case loading
    case error(String)
    case dismiss
}

protocol ChatViewModelProtocol: AnyObject {
    init(with appModel: AppModelProtocol)

    var viewState: BehaviorRelay<ChatViewStateEvent> {get}

    var chatMode: AppMode {get}

    var updateEvents: PublishRelay<Void> {get}

    var messages: [ChatMessageEntity] {get}

    func configureView()
    func postMessage(_ text: String)
    func stopChat()
}
