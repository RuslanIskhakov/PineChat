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

enum UpdateEvent {
    case update
    case updateAndScrollToBottom
    case updateAndScrollToNextMessage
    case updateAndScrollToPrevMessage
    case performBatchUpdate(Int)
}

protocol ChatViewModelProtocol: AnyObject {
    init(with appModel: AppModelProtocol)

    var viewState: BehaviorRelay<ChatViewStateEvent> {get}

    var chatMode: AppMode {get}

    var updateEvents: PublishSubject<UpdateEvent> {get}
    var title: PublishSubject<String> {get}
    var serverError: PublishSubject<Void> {get}
    var clientError: PublishSubject<Void> {get}
    var sendMessageError: PublishSubject<Void> {get}

    var messages: [ChatMessageEntity] {get}

    func configureView()
    func postMessage(_ text: String)
    func stopChat()
    func didScrollToTop()
    func didScrollToBottom()
}
