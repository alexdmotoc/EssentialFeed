//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Alex Motoc on 27.10.2023.
//

import UIKit

public struct CellController {
    private let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let prefetchDataSource: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable, dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource
        self.prefetchDataSource = dataSource
    }
    
    public init(id: AnyHashable, dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = nil
        self.prefetchDataSource = nil
    }
}

extension CellController: Hashable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
