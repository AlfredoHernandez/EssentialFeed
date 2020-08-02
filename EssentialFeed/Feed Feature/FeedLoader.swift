//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jesús Alfredo Hernández Alarcón on 28/07/20.
//

import Foundation

public typealias LoadFeedResult<Error: Swift.Error> = Result<[FeedItem], Error>

protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
