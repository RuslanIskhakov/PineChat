//
//  ServerSettingsViewController.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 16.11.2022.
//

import UIKit
import RxSwift

class ServerSettingsViewController: BaseViewController {

    @IBOutlet weak var startServerButton: UIButton!
    @IBOutlet weak var portNumberField: UITextField!
    @IBOutlet weak var ipAddressLabel: UILabel!

    private var viewModel: ServerSettingsViewModelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = ServerSettingsViewModel(with: AppDelegate.appModel)

        self.viewModel?.configureView()

        self.setupBindings()

        self.portNumberField.delegate = self
    }

    private func setupBindings() {

        self.viewModel?.ipAddressText
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] text in
                guard let self else { return }
                self.ipAddressLabel.text = text
            }).disposed(by: self.disposeBag)

        self.viewModel?.portNumberText
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] text in
                guard let self else { return }
                self.portNumberField.text = text
            }).disposed(by: self.disposeBag)

    }
    
    @IBAction func startServerTap(_ sender: Any) {
        self.dismissKeyboard()
        self.viewModel?.setPortNumber(self.portNumberField.text ?? "")
        self.viewModel?.startServerTap()
    }
}

extension ServerSettingsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: self, action: #selector(dismissKeyboard))
        navigationItem.rightBarButtonItem = rightButton
    }

    @objc
    func dismissKeyboard() {
        self.portNumberField.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
    }
}
