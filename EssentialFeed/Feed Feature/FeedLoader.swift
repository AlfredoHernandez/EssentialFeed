//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jesús Alfredo Hernández Alarcón on 28/07/20.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedItem], Error>

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
