//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 27.10.2023.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: CellController {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueCell()
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        return cell
    }
    
    public func preload(for cell: UITableViewCell?) {
        
    }
    
    public func cancelLoad() {
        
    }
}
