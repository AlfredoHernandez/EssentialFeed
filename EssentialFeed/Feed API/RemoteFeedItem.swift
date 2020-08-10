//
//  Created by Jesús Alfredo Hernández Alarcón on 09/08/20.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
	internal let id: UUID
	internal let description: String?
	internal let location: String?
	internal let image: URL
}
