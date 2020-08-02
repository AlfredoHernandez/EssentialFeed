//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jesús Alfredo Hernández Alarcón on 02/08/20.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
