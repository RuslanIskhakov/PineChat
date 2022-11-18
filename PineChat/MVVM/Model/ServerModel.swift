//
//  ServerModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import RxSwift

class ServerModel: BaseModelInitialisable, ServerModelProtocol {
    weak var appModel: AppModelProtocol?

    private var server: WebSocketServer?
    private let messagesCoder = SocketMessageCoder()

    override init() {
        super.init()

        self.messagesCoder.serverSideDelegate = self
    }

    func startServer() {
        print("SocketServerModel.startServer()")

        let portNumber = self.appModel?.appSettingsModel.portNumber ?? "8080"
        let port = UInt16(portNumber) ?? 8080
        let server = WebSocketServer(port: port)

        server.stateEvents
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] event in
                guard let self else { return }
                switch event {
                case .initial:
                    print("SocketServer state is initial")
                case .errorMessage(let msg):
                    print("SocketServer error: \(msg)")
                case .error(let error):
                    print("SocketServer error: \(error.localizedDescription)")
                case .opened(let msg):
                    print("SocketServer opened: \(msg)")
                case .event(let msg):
                    print("SocketServer event: \(msg)")
                }
            })
            .disposed(by: self.disposeBag)

        server.delegate = self
        server.startServer()
        self.server = server
    }

    func stopServer() {
        print("SocketServerModel.stopServer()")
        self.disposeBag = DisposeBag()
        self.server?.stopServer()
    }
}

private extension ServerModel {
    func getNewChatMessagesAvailableMessageData() -> Data? {
        self.messagesCoder.encodeMessage(
            NewChatMessagesAvailable(
                lastMessageId: self.appModel?.coreDataModel.getLastMessageId() ?? ""
            )
        )
    }
}

extension ServerModel: WebSocketServerDelegate {
    func dataReceived(_ data: Data) -> Data? {
        let message = self.messagesCoder.decodeClientMessage(from: data)
        print("Message received: \(message)")

        if let postMessage = message as? PostNewChatMessage {
            self.appModel?.coreDataModel.putNewMessage(postMessage)

            return self.getNewChatMessagesAvailableMessageData()
        }
        return nil
    }

    func newClientConnectionEstablished() -> Data? {
        self.getNewChatMessagesAvailableMessageData()
    }
}

extension ServerModel: SocketMessageParserServerSideDelegate {
    func chatMessagesRequested(_ message: ChatMessagesRequest) {

    }

    func chatMessagesPosted(_ message: PostNewChatMessage) {

    }
}
