//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreData
import Foundation

public final class CoreDataFeedStore: FeedStore {
    public init() {}

    public func retrieve(completion: @escaping RetreivalCompletion) {
        completion(.empty)
    }

    public func insert(_: [LocalFeedImage], timestamp _: Date, completion _: @escaping InsertionCompletion) {}

    public func deleteCachedFeed(completion _: @escaping DeletionCompletion) {}
}

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
