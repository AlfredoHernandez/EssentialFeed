//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Jesús Alfredo Hernández Alarcón on 28/07/20.
//

import Foundation

protocol FeedLoader {
    func load(completion: @escaping ((Result<[FeedItem], Error>) -> Void))
}
