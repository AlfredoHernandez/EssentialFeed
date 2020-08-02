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
        let task = session.dataTask(with: url) { (_, _, _) in }.resume()
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
    
    func test_getFromUrl_resumesDataTaskWithURL() {
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: - Test helpers
    
    class URLSessionSpy: URLSession {
        var receivedUrls = [URL]()
        private var stubs = [URL: URLSessionDataTask]()
        
        override init() { }
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return stubs[url] ?? URLSessionDataTaskFake()
        }
    }
    
    class URLSessionDataTaskFake: URLSessionDataTask {
        override init() { }
    }
    
    class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override init() { }
        
        override func resume() {
            super.resume()
            resumeCallCount += 1
        }
    }
}
