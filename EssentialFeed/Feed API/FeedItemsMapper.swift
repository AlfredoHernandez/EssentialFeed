//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Jesús Alfredo Hernández Alarcón on 02/08/20.
//

import Foundation

internal final class FeedItemMapper {
    private static let OK_200 = 200
    
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] { items.map { $0.item } }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id,
                     description: description,
                     location: location,
                     imageURL: image)
        }
    }
    
    internal static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        return .success(root.feed)
    }
}
