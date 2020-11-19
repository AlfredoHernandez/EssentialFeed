//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class FeedImageDataMapper {
    enum Error: Swift.Error {
        case invalidData
    }

    public static func map(data: Data, response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else { throw Error.invalidData }
        return data
    }
}
