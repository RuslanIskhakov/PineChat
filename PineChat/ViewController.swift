//
//  ViewController.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 16.11.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        let coreDataModel = CoreDataModel()

//        coreDataModel.putMessage(from: "Mike Anderson", text: "Hi! Anybody here?", id: UUID().uuidString)
//        coreDataModel.putMessage(from: "Arnold Smith", text: "Nope!!!", id: UUID().uuidString)

        coreDataModel.getAllMessages().forEach{print("Message: \($0)")}
        print("==========================")
        coreDataModel.getAllMessagesSortedByDate().forEach{print("Message: \($0)")}
        print("==========================")
        coreDataModel.getAllMessagesSortedByDate(limit: 2).forEach{print("Message: \($0)")}
        print("==========================")
        coreDataModel.getAllMessagesSortedByDate(limit: 1).forEach{print("Message: \($0)")}
    }


}

