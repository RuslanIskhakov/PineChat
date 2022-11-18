//
//  UITableView+Scroll.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 18.11.2022.
//

import UIKit

extension UITableView {
    func scrollToTop(){
        DispatchQueue.main.async {[weak self] in
            guard let strongSelf = self else {return}
            if let datasource = strongSelf.dataSource  {
                let rows = datasource.tableView(strongSelf, numberOfRowsInSection: 0)
                if rows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    strongSelf.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
        }
    }
    func scrollToBottom(){
        DispatchQueue.main.async {[weak self] in
            guard let strongSelf = self else {return}
            if let datasource = strongSelf.dataSource  {
                let rows = datasource.tableView(strongSelf, numberOfRowsInSection: 0)
                if rows > 0 {
                    let indexPath = IndexPath(row: rows - 1, section: 0)
                    strongSelf.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
}
