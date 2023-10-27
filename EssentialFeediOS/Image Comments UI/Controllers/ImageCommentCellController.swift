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
        UITableViewCell()
    }
    
    public func preload(for cell: UITableViewCell?) {
        
    }
    
    public func cancelLoad() {
        
    }
}
