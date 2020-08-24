//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import UIKit

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public final class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]()
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()

    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }

    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return tableModel.count
    }

    override public func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        tasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
            let data = try? result.get()
            cell?.feedImageView.image = data.map(UIImage.init) ?? nil
            cell?.feedImageContainer.stopShimmering()
        }
        return cell
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
