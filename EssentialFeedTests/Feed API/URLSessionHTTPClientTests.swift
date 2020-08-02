//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Jesús Alfredo Hernández Alarcón on 02/08/20.
//

import XCTest
import EssentialFeed

protocol HTTPSessionDataTask {
    func resume()
}

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromUrl_resumesDataTaskWithURL() {
        let url = URL(string: "http://a-url.com")!
        let session = HTTPSessionStub()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url){ _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://a-url.com")!
        let session = HTTPSessionStub()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError):
                XCTAssertEqual(receivedError as NSError, error)
            default:
                XCTFail("Expected failure error \(error), got result \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Test helpers
    
    class HTTPSessionStub: HTTPSession {
        private var stubs = [URL: Stub]()
        
        struct Stub {
            let task: HTTPSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionDataTask = URLSessionDataTaskFake(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
            guard let stub = stubs[url] else { fatalError("Couldn't find stub for \(url)") }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    class URLSessionDataTaskFake: HTTPSessionDataTask {
        func resume() { }
    }
    
    class URLSessionDataTaskSpy: HTTPSessionDataTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
