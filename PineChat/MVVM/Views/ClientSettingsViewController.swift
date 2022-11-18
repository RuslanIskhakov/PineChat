//
//  ClientSettingsViewController.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 16.11.2022.
//

import UIKit
import RxSwift

class ClientSettingsViewController: BaseViewController {

    @IBOutlet weak var usernameView: UITextField!
    @IBOutlet weak var ipAddressField: UITextField!
    @IBOutlet weak var portNumberField: UITextField!
    private var viewModel: ClientSettingsViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = ClientSettingsViewModel(with: AppDelegate.appModel)

        self.title = ""

        self.viewModel?.configureView()

        self.setupBindings()

        self.ipAddressField.delegate = self
        self.portNumberField.delegate = self
        self.usernameView.delegate = self
    }

    private func setupBindings() {

        self.viewModel?.ipAddressText
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] text in
                guard let self else { return }
                self.ipAddressField.text = text
            }).disposed(by: self.disposeBag)

        self.viewModel?.portNumberText
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] text in
                guard let self else { return }
                self.portNumberField.text = text
            }).disposed(by: self.disposeBag)

        self.viewModel?.usernameText
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] text in
                guard let self else { return }
                self.usernameView.text = text
            }).disposed(by: self.disposeBag)

    }

    @IBAction func enterChat(_ sender: Any) {
        self.viewModel?.setUsername(self.usernameView.text ?? "")
        self.viewModel?.setServerIPAddress(self.ipAddressField.text ?? "")
        self.viewModel?.setPortNumber(self.portNumberField.text ?? "")
        self.viewModel?.enterChatTap()
    }
}

extension ClientSettingsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: self, action: #selector(dismissKeyboard))
        navigationItem.rightBarButtonItem = rightButton
    }

    @objc
    func dismissKeyboard() {
        self.ipAddressField.resignFirstResponder()
        self.portNumberField.resignFirstResponder()
        self.usernameView.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
    }
}
