//
//  ClientModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import RxSwift

class ClientModel: BaseModelInitialisable, ClientModelProtocol {
    weak var appModel: AppModelProtocol?

    private var client: WebSocketClient?

    func startClient() {
        print("Starting WebSocketClient")
        let serverIPAddress = self.appModel?.appSettingsModel.serverIPAddress ?? ""
        let portNumber = self.appModel?.appSettingsModel.portNumber ?? "8080"
        self.client = WebSocketClient(ipAddress: serverIPAddress, port: portNumber)

        self.client?.connectionEvents
            .subscribe(on: SerialDispatchQueueScheduler(qos: .utility))
            .observe(on: SerialDispatchQueueScheduler(qos: .utility))
            .subscribe(onNext: { [weak self] event in
                guard let self else { return }
                switch event {
                case .connected:
                    break
                case .locationAck:
                    break
                }

            })
            .disposed(by: self.disposeBag)

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

        self.client?.subscribeToService()
    }

    func stopClient() {
        self.disposeBag = DisposeBag()
        self.client?.closeSocket()
        self.client = nil
    }
}
