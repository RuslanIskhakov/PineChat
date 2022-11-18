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

    func startServer() {
        print("SocketServerModel.startServer()")

        let portNumber = self.appModel?.appSettingsModel.portNumber ?? "8080"
        let port = UInt16(portNumber) ?? 8080
        let server = WebSocketServer(port: port)

        server.startServer()
        self.server = server
    }

    func stopServer() {
        print("SocketServerModel.stopServer()")

        self.server?.stopServer()
    }
}
