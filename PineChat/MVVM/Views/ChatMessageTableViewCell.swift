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

    @IBOutlet weak var messageContainer: UIView!
    
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

        self.leadingConstraint.constant = 8
        self.trailingConstraint.constant = 8
        self.userNameLabel.text = nil
        self.timestampLabel.text = nil
        self.messageLabel.text = nil

        self.messageContainer.backgroundColor = .clear
    }

    public func setup(with message: ChatMessageEntity) {
        switch message.type {
        case .incoming:
            self.leadingConstraint.constant = 8
            self.trailingConstraint.constant = 32
        case .outgoing:
            self.leadingConstraint.constant = 32
            self.trailingConstraint.constant = 8
        }

        self.userNameLabel.text = message.userName
        self.messageLabel.text = message.text
        if let date = message.date {
            self.timestampLabel.text = self.formatter.string(from: date)
        } else {
            self.timestampLabel.text = ""
        }

        self.messageContainer.backgroundColor =
            message.type == .incoming ?
            UIColor.white :
            UIColor(red: 223, green: 253, blue: 212)

        self.setNeedsLayout()
    }
    
}
