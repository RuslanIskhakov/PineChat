//
//  ChatViewController.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import UIKit
import RxSwift

class ChatViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendMessageContainerView: UIView!

    private var viewModel: ChatViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = ChatViewModel(with: AppDelegate.appModel)

        self.setupBindings()

        self.setupUI()

        self.addCustomBackButton()

        DispatchQueue.main.async {[weak self] in
            guard let self else { return }
            self.viewModel?.configureView()

            if self.viewModel?.chatMode == .server {
                self.bottomConstraint.constant = -(self.sendMessageContainerView.frame.height + self.view.safeAreaInsets.bottom)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        notificationCenter.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }

    @IBAction func sendTap(_ sender: Any) {
        if
            let message = self.textView.text,
            !message.isEmpty
        {
            self.viewModel?.postMessage(message)
            self.textView.text = nil
            self.dismissKeyboard()
        }
    }

    private func setupBindings() {

        self.viewModel?.updateEvents
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] event in
                guard let self else { return }
                switch event {
                case .update:
                    self.tableView.reloadData()
                case .updateAndScrollToBottom:
                    self.tableView.reloadData()
                    self.tableView.scrollToBottom()
                case .updateAndScrollToNextMessage:
                    self.tableView.reloadData()
                    self.tableView.scrollToBottom()
                case .updateAndScrollToPrevMessage:
                    self.tableView.reloadData()
                    self.tableView.scrollToTop()
                case .performBatchUpdate(let newRowsNum):
                    var indexPathes = [IndexPath]()
                    for i in 0..<newRowsNum {indexPathes.append(IndexPath(row: i, section: 0))}
                    self.tableView.performBatchUpdates({
                        self.tableView.insertRows(at: indexPathes, with: .automatic)
                    }){[weak self] _ in
                        self?.tableView.reloadData()
                    }
                }
            }).disposed(by: self.disposeBag)

        self.viewModel?.viewState
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] event in
                guard let self else { return }
                switch event {
                case .dismiss:
                    self.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            }).disposed(by: self.disposeBag)

        self.viewModel?.title
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] title in
                guard let self else { return }
                self.title = title
            }).disposed(by: self.disposeBag)

        self.viewModel?.serverError
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                self.showServerErrorDialog()
            }).disposed(by: self.disposeBag)

        self.viewModel?.clientError
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                self.showClientErrorDialog()
            }).disposed(by: self.disposeBag)

        self.viewModel?.sendMessageError
            .observe(on: MainScheduler.instance)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                self.showSendMessageErrorDialog()
            }).disposed(by: self.disposeBag)
    }
}

private extension ChatViewController {
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            self.bottomConstraint.constant = 0
        } else {
            self.bottomConstraint.constant = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        }
    }

    func addCustomBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(named: "backIcon")?.withTintColor(self.view.tintColor),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTap(_:)))
        self.navigationItem.leftBarButtonItem = backButton
    }

    func setupUI() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)

        self.textView.delegate = self

        self.tableView.register(UINib(nibName: "ChatMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "chatMessage")
        self.tableView.allowsSelection = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44
        self.tableView.contentInsetAdjustmentBehavior = .never
    }

    @objc
    func backButtonTap(_ sender: Any) {

        let title: String
        let message: String

        switch self.viewModel?.chatMode {
        case .server:
            title = "???????????????????? ?????????????"
            message = "?????? ??????????????????????, ???? ?????? ?????????????????? ?????????????????? ???????????????????? ?????? ?????????????????? ?????????????? ??????????????."
        default:
            title = "?????????? ???? ?????????"
            message = ""
        }

        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancel = UIAlertAction(title: "??????", style: .cancel, handler: { _ in

        })

        let ok = UIAlertAction(title: "????", style: .default, handler: { _ in
            self.viewModel?.stopChat()
        })

        dialog.addAction(cancel)
        dialog.addAction(ok)
        self.present(dialog, animated: true, completion: nil)
    }

    func showServerErrorDialog() {
        let dialog = UIAlertController(title: "???????????? ??????????????", message: "???? ?????????????? ?????????????? ??????????-????????????. ????????????????????, ?????????????????? ?????????? ?????????????????? ?????????? ?????? ???????????????? ?????????? ??????????.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "????", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        })

        dialog.addAction(ok)
        self.present(dialog, animated: true, completion: nil)
    }

    func showSendMessageErrorDialog() {
        let dialog = UIAlertController(title: "????????????", message: "?????????????????? ???? ???????? ????????????????????. ????????????????????, ???????????????????? ??????????", preferredStyle: .alert)

        let ok = UIAlertAction(title: "????", style: .default, handler: nil)

        dialog.addAction(ok)
        self.present(dialog, animated: true, completion: nil)
    }

    func showClientErrorDialog() {
        let dialog = UIAlertController(title: "???????????? ??????????????????????", message: "???? ?????????????? ???????????????????????? ?? ??????????-??????????????. ????????????????????, ?????????????????? ?????????? ??????????.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "????", style: .default, handler: { _ in
            self.viewModel?.stopChat()
        })

        dialog.addAction(ok)
        self.present(dialog, animated: true, completion: nil)
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down")?.withTintColor(self.view.tintColor), style: .done, target: self, action: #selector(dismissKeyboard))
        navigationItem.rightBarButtonItem = rightButton
    }

    @objc
    func dismissKeyboard() {
        self.textView.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if
            let message = self.viewModel?.messages[indexPath.row],
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "chatMessage", for: indexPath) as? ChatMessageTableViewCell {
            cell.setup(with: message)
            return cell
        }

        return UITableViewCell(frame: .zero)
    }

    func numberOfSections(in tableView: UITableView) -> Int {1}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.messages.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.tableView.contentSize.height > self.tableView.frame.height {
            if indexPath.row == 0 {
                self.viewModel?.didScrollToTop()
            }
        }
    }
}
