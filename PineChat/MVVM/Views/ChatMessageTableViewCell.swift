//
//  ChatMessageTableViewCell.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM HH:mm"
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.leadingConstraint.constant = 0
        self.trailingConstraint.constant = 0
        self.userNameLabel.text = nil
        self.timestampLabel.text = nil
        self.messageLabel.text = nil
    }

    public func setup(with message: ChatMessageEntity) {
        switch message.type {
        case .incoming:
            self.leadingConstraint.constant = 0
            self.trailingConstraint.constant = 56
        case .outgoing:
            self.leadingConstraint.constant = 56
            self.trailingConstraint.constant = 0
        }

        self.userNameLabel.text = message.userName
        self.messageLabel.text = message.text
        if let date = message.date {
            self.timestampLabel.text = self.formatter.string(from: date)
        } else {
            self.timestampLabel.text = ""
        }

        self.layoutIfNeeded()
    }
    
}
