//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Jesús Alfredo Hernández Alarcón on 02/08/20.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { (_, _, _) in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromUrl_createsDataTaskWithURL() {
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedUrls, [url])
    }
    
    // MARK: - Test helpers
    
    class URLSessionSpy: URLSession {
        var receivedUrls = [URL]()
        
        override init() { }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return URLSessionDataTaskFake()
        }
    }
    
    class URLSessionDataTaskFake: URLSessionDataTask {
        override init() { }
    }
}
