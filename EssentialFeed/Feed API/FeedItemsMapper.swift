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
		let items: [RemoteFeedItem]
    }
    
    internal static func map(data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
