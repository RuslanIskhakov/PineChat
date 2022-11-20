//
//  BaseModelInitialisable.swift
//  PineChat
//
//  Created by Ruslan Iskhakov on 17.11.2022.
//

import RxSwift

class BaseModelInitialisable: NSObject {
    override init() {
        super.init()
        print("\(String(describing: type(of: self))) initialised")
    }

    var disposeBag = DisposeBag()
}
