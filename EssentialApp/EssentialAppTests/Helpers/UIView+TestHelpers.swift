//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Jesús Alfredo Hernández Alarcón on 13/10/20.
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
