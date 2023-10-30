//
//  LoadMoreCellController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 30.10.2023.
//

import UIKit
import EssentialFeed

public final class LoadMoreCellController: NSObject, UITableViewDataSource {
    private lazy var cell = LoadMoreCell()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}
