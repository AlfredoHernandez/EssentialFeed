//
//  Created by Jesús Alfredo Hernández Alarcón on 09/08/20.
//

import Foundation

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	
	func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
