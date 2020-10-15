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

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Swift.Error>

    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?

        return Deferred {
            Future { completion in
                task = loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Data {
    func catching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data: data, for: url)
        }).eraseToAnyPublisher()
    }
}

public extension FeedImageDataCache {
    func saveIgnoringResult(data: Data, for url: URL) {
        save(data, for: url, completion: { _ in })
    }
}

public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Swift.Error>

    func loadPublisher() -> Publisher {
        Deferred { Future(load) }.eraseToAnyPublisher()
    }
}

public extension Publisher where Output == [FeedImage] {
    func catching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { feed in
            cache.saveIgnoringResult(feed)
        }).eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

public extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler = ImmediateWhenOnMainQueueScheduler()

    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        var now: DispatchQueue.SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            action()
        }

        func schedule(
            after date: DispatchQueue.SchedulerTimeType,
            tolerance: DispatchQueue.SchedulerTimeType.Stride,
            options: DispatchQueue.SchedulerOptions?,
            _ action: @escaping () -> Void
        ) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        func schedule(
            after date: DispatchQueue.SchedulerTimeType,
            interval: DispatchQueue.SchedulerTimeType.Stride,
            tolerance: DispatchQueue.SchedulerTimeType.Stride,
            options: DispatchQueue.SchedulerOptions?,
            _ action: @escaping () -> Void
        ) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}
