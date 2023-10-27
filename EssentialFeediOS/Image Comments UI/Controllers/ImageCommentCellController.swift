//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 27.10.2023.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: NSObject {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
}

// MARK: - UITableViewDataSource

extension ImageCommentCellController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueCell()
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        return cell
    }
}
