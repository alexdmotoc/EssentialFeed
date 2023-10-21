//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Alex Motoc on 21.10.2023.
//

import UIKit

extension UIView {
    func enforceLayout() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
