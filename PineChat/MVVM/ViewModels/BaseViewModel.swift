//
//  BaseViewModel.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import RxSwift

class BaseViewModel {
    init() {
        print("\(String(describing: type(of: self))) created")
    }

    var disposeBag = DisposeBag()

    deinit {
        print("deinit for \(String(describing: type(of: self)))")
    }
}
