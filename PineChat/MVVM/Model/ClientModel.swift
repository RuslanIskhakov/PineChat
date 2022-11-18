//
//  ClientModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import RxSwift

class ClientModel: BaseModelInitialisable, ClientModelProtocol {
    weak var appModel: AppModelProtocol?

    let chatMessagesFromServer = PublishSubject<ChatMessagesResponse>()

    private var client: WebSocketClient?
    private let messagesCoder = SocketMessageCoder()
    private let queue = DispatchQueue(label: "ClientModel", qos: .utility)

    override init() {
        super.init()

        self.messagesCoder.clientSideDelegate = self
    }

    func startClient() {
        print("Starting WebSocketClient")
        let serverIPAddress = self.appModel?.appSettingsModel.serverIPAddress ?? ""
        let portNumber = self.appModel?.appSettingsModel.portNumber ?? "8080"
        self.client = WebSocketClient(ipAddress: serverIPAddress, port: portNumber)

        self.client?.serverLocation
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] location in
                guard let self else { return }

            })
            .disposed(by: self.disposeBag)

        self.client?.stateEvents
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] event in
                guard let self else { return }
                switch event {
                case .initial:
                    print("SocketClient state is initial")
                case .errorMessage(let msg):
                    print("SocketClient error: \(msg)")
                case .error(let error):
                    print("SocketClient error: \(error.localizedDescription)")
                case .opened(let msg):
                    print("SocketClient opened: \(msg)")
                case .event(let msg):
                    print("SocketClient event: \(msg)")
                }
            })
            .disposed(by: self.disposeBag)

        self.client?.delegate = self
        self.client?.subscribeToService()
    }

    func stopClient() {
        self.disposeBag = DisposeBag()
        self.client?.closeSocket()
        self.client = nil
    }

    func postChatMessage(_ text: String) {
        self.queue.async {[unowned self] in
            guard
                let username = self.appModel?.appSettingsModel.username,
                let data = self.messagesCoder.encodeMessage(
                    PostNewChatMessage(
                        userName: username,
                        message: text
                    ))
            else { return }

            self.client?.send(data)
        }
    }

    func requestChatMessages(from id: String, ahead: Bool, limit: Int) {
        self.queue.async {[unowned self] in
            guard
                let data = self.messagesCoder.encodeMessage(
                    ChatMessagesRequest(
                        fromId: id,
                        ahead: ahead,
                        limit: 10)
                )
            else { return }

            self.client?.send(data)
        }
    }
}

extension ClientModel: WebSocketClientDelegate {
    func messageReceived(_ data: Data) {
        guard
            let _ = self.messagesCoder.decodeServerMessage(from: data)
        else {
            print("cannot decode data :(")
            return
        }
    }
}

extension ClientModel: SocketMessageParserClientSideDelegate {
    func newChatMessagesAvailable(_ message: NewChatMessagesAvailable) {
        self.requestChatMessages(from: message.lastMessageId, ahead: false, limit: 10)
    }

    func chatMessagesResponse(_ message: ChatMessagesResponse) {
        self.chatMessagesFromServer.onNext(message)
    }
}
