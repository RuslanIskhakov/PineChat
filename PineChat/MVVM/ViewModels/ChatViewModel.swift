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

    var messages = [ChatMessageEntity]()

    func configureView() {

        self.chatMode = self.appModel.mode ?? .client
        if self.appModel.mode == .server {
            self.appModel.serverModel.startServer()
        } else {
            self.appModel.clientModel.startClient()
        }

        self.setupBindings()

        //self.fillWithDummyMessages()

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
}

private extension ChatViewModel {

    func showLastMessages() {
        let lastId = self.appModel.coreDataModel.getLastMessageId()
        let cdMessages =
            self.appModel.coreDataModel.getMessages(from: lastId, ahead: false, limit: 10)
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
        if self.chatMode == .server {
            self.appModel.coreDataModel.newChatMessagePosted
                .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    guard let self else { return }
                    self.showLastMessages()
                })
                .disposed(by: self.disposeBag)
        } else {
            self.appModel.clientModel.chatMessagesFromServer
                .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
                .observe(on: SerialDispatchQueueScheduler(qos: .utility))
                .subscribe(onNext: { [weak self] response in
                    guard let self else { return }
                    let newMessages = response.chatMessages
                        .map{ChatMessageEntity(
                            id: $0.id,
                            date: $0.date,
                            userName: $0.userName,
                            text: $0.text,
                            type: $0.userName == self.username ? .outgoing : .incoming
                        )}
                    DispatchQueue.main.async {[weak self] in
                        guard let self else { return }
                        self.messages.removeAll()
                        self.messages.append(contentsOf: newMessages)
                        self.updateEvents.onNext(.updateAndScrollToBottom)
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }

    func fillWithDummyMessages() {
        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "123                                                                                          456",
                type: .outgoing)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                type: .outgoing)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "Lorem ipsum dolor sit amet",
                type: .outgoing)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "123",
                type: .incoming)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov Ivan Ivanov Ivan Ivanov Ivan Ivanov Ivan Ivanov Ivan Ivanov ",
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                type: .outgoing)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "Lorem ipsum dolor sit amet",
                type: .outgoing)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "123",
                type: .outgoing)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                type: .incoming)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "Lorem ipsum dolor sit amet",
                type: .outgoing)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "123",
                type: .outgoing)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                type: .outgoing)
        )

        self.messages.append(
            ChatMessageEntity(
                id: "",
                date: Date(),
                userName: "Ivan Ivanov",
                text: "Lorem ipsum dolor sit amet",
                type: .outgoing)
        )
    }
}
