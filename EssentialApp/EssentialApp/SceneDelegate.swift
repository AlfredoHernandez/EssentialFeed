//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import CoreData
import EssentialFeed
import EssentialFeediOS
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite")
        )
    }()

    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        configureWindow()
    }

    func configureWindow() {
        let remoteURL =
            URL(
                string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json"
            )!
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        let loaderAsPublisher = remoteFeedLoader
            .loadPublisher()
            .catching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)

        window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: { loaderAsPublisher },
            imageLoader: localImageLoaderWithRemoteFallbackPublisher
        ))

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_: UIScene) {
        localFeedLoader.validateCache { _ in }
    }

    private func localImageLoaderWithRemoteFallbackPublisher(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .catching(to: localImageLoader, using: url)
            })
    }
}
