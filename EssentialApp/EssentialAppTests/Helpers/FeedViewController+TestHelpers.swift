//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeediOS
import UIKit

extension ListViewController {
    override public func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }

    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var errorMessage: String? {
        errorView.message
    }

    func simulateErrorViewTap() {
        errorView.simulateTap()
    }

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
}

extension ListViewController {
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }

    @discardableResult
    func simulateFeedImageViewNotVisible(at index: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: index)

        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImagesSection)

        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)

        return view
    }

    func simulateFeedImageViewNearVisible(at index: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)

        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }

    func simulateFeedImageViewNotNearVisible(at index: Int) {
        simulateFeedImageViewNearVisible(at: index)

        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImagesSection)

        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }

    func renderedFeedImageData(at index: Int = 0) -> Data? {
        simulateFeedImageViewVisible(at: index)?.renderedImage
    }

    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }

    var feedImagesSection: Int { 0 }

    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }

    func simulateTapOnFeedImage(at row: Int = 0) {
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}

extension ListViewController {
    var commentsSection: Int { 0 }

    func numberOfRenderedComments() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }

    func commentMessage(at row: Int = 0) -> String? {
        commentView(at: row)?.messageLabel.text
    }

    func commentDate(at row: Int = 0) -> String? {
        commentView(at: row)?.dateLabel.text
    }

    func commentUsername(at row: Int = 0) -> String? {
        commentView(at: row)?.usernameLabel.text
    }

    private func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedComments() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? ImageCommentCell
    }
}
