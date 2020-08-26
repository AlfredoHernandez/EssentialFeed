//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())

    private let viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        viewModel.loadFeed()
    }

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        return view
    }
}
