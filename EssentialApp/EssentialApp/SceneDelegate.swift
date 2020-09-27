//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import CoreData
import EssentialFeed
import EssentialFeediOS
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var localStoreURL: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: localStoreURL)
    }()

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        configureWindow()
    }

    func configureWindow() {
        let remoteURL =
            URL(
                string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json"
            )!
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)

        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader),
                fallback: localFeedLoader
            ),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)
            )
        ))
    }

    func makeRemoteClient() -> HTTPClient { httpClient }
}
