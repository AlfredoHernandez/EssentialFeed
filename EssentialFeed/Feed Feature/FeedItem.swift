//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Jesús Alfredo Hernández Alarcón on 28/07/20.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
