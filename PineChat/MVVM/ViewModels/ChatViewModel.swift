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

    required init(with appModel: AppModelProtocol) {
        self.appModel = appModel
    }

    let viewState = BehaviorRelay<ChatViewStateEvent>(value: .idle)

    let updateEvents = PublishRelay<Void>()

    var messages = [ChatMessageEntity]()

    func configureView() {

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

        self.updateEvents.accept(())
    }
}
