//
//  ClientSettingsViewController.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 16.11.2022.
//

import UIKit

class ClientSettingsViewController: UIViewController {

    private var viewModel: ClientSettingsViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = ClientSettingsViewModel(with: AppDelegate.appModel)

        self.title = "Клиент"
    }
}
