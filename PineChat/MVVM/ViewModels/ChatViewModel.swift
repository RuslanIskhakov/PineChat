//
//  ChatViewModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import RxSwift
import RxRelay

class ChatViewModel: BaseViewModel, ChatViewModelProtocol {

    private let appModel: AppModelProtocol

    private lazy var username: String = {
        self.appModel.appSettingsModel.username
    }()

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
    }

    var chatMode: AppMode = .client
    let viewState = BehaviorRelay<ChatViewStateEvent>(value: .idle)
    let updateEvents = PublishSubject<UpdateEvent>()
    let title = PublishSubject<String>()
    let serverError = PublishSubject<Void>()
    let clientError = PublishSubject<Void>()
    let sendMessageError = PublishSubject<Void>()

    var messages = [ChatMessageEntity]()

    func configureView() {

        self.chatMode = self.appModel.mode ?? .client
        if self.appModel.mode == .server {
            self.appModel.serverModel.startServer()
        } else {
            self.appModel.clientModel.startClient()
        }

        self.setupBindings()

        if self.chatMode == .server {
            self.showLastMessages()
        } else {
            self.updateEvents.onNext(.update)
        }

        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            self.title.onNext(
                self.chatMode == .server ?
                "\(self.appModel.connectivityUtils.getIP() ?? "???"):\(self.appModel.appSettingsModel.portNumber)" :
                "Чат у сосны"
            )

        }
    }

    func postMessage(_ text: String) {
        self.appModel.clientModel.postChatMessage(text)
    }

    func stopChat() {
        if self.chatMode == .server {
            self.appModel.serverModel.stopServer()
            self.viewState.accept(.dismiss)
        } else {
            self.appModel.clientModel.stopClient()
            self.viewState.accept(.dismiss)
        }
    }

    func didScrollToTop() {
        if self.chatMode == .client {

            guard self.messages.count > 0 else { return }

            self.appModel.clientModel.requestChatMessages(
                from: self.messages[0].id,
                ahead: false,
                limit: 10)
            }
        }

    func didScrollToBottom() {
//        if self.chatMode == .client {
//            self.appModel.clientModel.requestChatMessages(
//                from: self.messages[self.messages.count - 1].id,
//                ahead: true,
//                limit: 10)
//        }
    }
}

private extension ChatViewModel {

    func showLastMessages() {
        let lastId = self.appModel.coreDataModel.getLastMessageId()
        let cdMessages =
            self.appModel.coreDataModel.getMessages(from: lastId, ahead: false, limit: 500)
            .map{ChatMessageEntity(
                id: $0.id,
                date: $0.date,
                userName: $0.userName,
                text: $0.text,
                type: .incoming
            )}
        self.messages.removeAll()
        self.messages.append(contentsOf: cdMessages)
        self.updateEvents.onNext(.updateAndScrollToBottom)
    }

    func setupBindings() {

        self.appModel.coreDataModel.newChatMessagePosted
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                guard self.chatMode == .server else { return }
                self.showLastMessages()
            })
            .disposed(by: self.disposeBag)

        self.appModel.clientModel.chatMessagesFromServer
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] response in
                guard let self else { return }
                guard self.chatMode == .client else { return }
                self.appendNewMessages(from: response)
            })
            .disposed(by: self.disposeBag)

        self.appModel.serverErrorEvents
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                guard self.chatMode == .server else { return }
                self.appModel.serverModel.stopServer()
                self.serverError.onNext(())
            })
            .disposed(by: self.disposeBag)

        self.appModel.clientErrorEvents
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                guard self.chatMode == .client else { return }
                self.appModel.clientModel.stopClient()
                self.clientError.onNext(())
            })
            .disposed(by: self.disposeBag)

        self.appModel.sendMessageErrorEvents
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                guard self.chatMode == .client else { return }
                self.sendMessageError.onNext(())
            })
            .disposed(by: self.disposeBag)

    }

    func appendNewMessages(from response: ChatMessagesResponse) {

        var newMessages = response.chatMessages
            .map{ChatMessageEntity(
                id: $0.id,
                date: $0.date,
                userName: $0.userName,
                text: $0.text,
                type: $0.userName == self.username ? .outgoing : .incoming
            )}

        if let _ = newMessages.firstIndex(where: {$0.type == .incoming}) {
            self.appModel.hapticFeedbackModel.makeFeedback()
        }

        var oldMessages = self.messages

        if oldMessages.count == 0 {
            self.replaceCurrentMessagesWith(
                newMessages,
                update: .updateAndScrollToBottom
            )
        } else {
            let searchDepth = newMessages.count

            if
                let firstOldIndex = oldMessages.firstIndex(where: {$0.id == response.fromId}),
                firstOldIndex < searchDepth - 1
            {
                let rowsToUpdate = response.chatMessages.count - 1 - firstOldIndex
                if rowsToUpdate > 0 {
                    newMessages.append(contentsOf: oldMessages[firstOldIndex+1..<oldMessages.count])
                    self.replaceCurrentMessagesWith(
                        newMessages,
                        update: .performBatchUpdate(rowsToUpdate)
                    )
                }
            } else {
                let searchId = oldMessages[oldMessages.count - 1].id
                if let firstNewIndex = newMessages.firstIndex(where: {$0.id == searchId}) {
                    oldMessages.append(contentsOf: newMessages[firstNewIndex+1..<searchDepth])
                    self.replaceCurrentMessagesWith(
                        oldMessages,
                        update: .updateAndScrollToNextMessage
                    )
                }
            }
        }
    }

    func replaceCurrentMessagesWith(
        _ newMessages: [ChatMessageEntity],
        update with: UpdateEvent
    ) {
        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            self.messages.removeAll()
            self.messages.append(contentsOf: newMessages)
            self.updateEvents.onNext(with)
        }
    }
}
