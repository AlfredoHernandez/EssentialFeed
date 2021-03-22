//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}

private class DummyView: ResourceView {
    func display(_: Any) {}
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}
