//
//  UITableView+Utils.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 16.10.2023.
//

import UIKit

extension UITableView {
    func dequeueCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
    
    func autoSizeHeader() {
        guard let tableHeaderView else { return }
        
        let autoSize = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if tableHeaderView.frame.height != autoSize.height {
            tableHeaderView.frame.size.height = autoSize.height
            self.tableHeaderView = tableHeaderView
        }
    }
}
