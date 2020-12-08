//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

public struct CellController {
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?

    public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.dataSource = dataSource
        delegate = dataSource
        dataSourcePrefetching = dataSource
    }

    public init(_ dataSource: UITableViewDataSource) {
        self.dataSource = dataSource
        delegate = nil
        dataSourcePrefetching = nil
    }
}
