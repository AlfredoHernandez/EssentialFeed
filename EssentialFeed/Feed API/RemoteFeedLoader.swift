//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Jesús Alfredo Hernández Alarcón on 29/07/20.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void){
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
				completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		do {
			let items = try FeedItemMapper.map(data: data, response: response)
			return .success(items.toModels())
		}catch {
			return .failure(error)
		}
	}
}

extension Array where Element == RemoteFeedItem {
	func toModels() -> [FeedItem] {
		map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
	}
}
