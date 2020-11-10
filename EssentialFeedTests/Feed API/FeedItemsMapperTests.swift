//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeed
import XCTest

class FeedItemsMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResonse() throws {
        let samples = [199, 201, 300, 400, 500]
        let json = makeItemsJSON([])

        try samples.forEach { code in
            XCTAssertThrowsError(try FeedItemMapper.map(data: json, response: HTTPURLResponse(statusCode: code)))
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(try FeedItemMapper.map(data: invalidJSON, response: HTTPURLResponse(statusCode: 200)))
    }

    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON([])

        let result = try FeedItemMapper.map(data: emptyListJSON, response: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [], "Expected no items, but got \(result) instead.")
    }

    func tests_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "https://a-url.com")!
        )

        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://another-url.com")!
        )

        let json = makeItemsJSON([item1.json, item2.json])
        let result = try FeedItemMapper.map(data: json, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [item1.model, item2.model])
    }

    // MARK: Tests helpers

    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.url.absoluteString,
        ].compactMapValues { $0 }
        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
