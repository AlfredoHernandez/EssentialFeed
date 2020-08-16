//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() {}

    public func retrieve(completion: @escaping RetreivalCompletion) {
        completion(.empty)
    }

    public func insert(_: [LocalFeedImage], timestamp _: Date, completion _: @escaping InsertionCompletion) {}

    public func deleteCachedFeed(completion _: @escaping DeletionCompletion) {}
}
