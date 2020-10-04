//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import EssentialFeed
import EssentialFeediOS
import XCTest

class FeedSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()

        sut.display(emptyFeed())

        assert(snapshot: sut.snapshot(), named: "empty_feed")
    }

    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(), named: "feed_with_content")
    }

    func test_feed_withError() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(), named: "feed_with_error_message")
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(), named: "feed_with_failed_image_loading")
    }

    // MARK: - Helpers

    func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }

    private func emptyFeed() -> [FeedImageCellController] {
        []
    }

    private func feedWithContent() -> [ImageStub] {
        [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            ),
        ]
    }

    private func feedWithFailedImageLoading() -> [ImageStub] {
        [
            ImageStub(
                description: nil,
                location: "Bellas Artes Palace, Mexico",
                image: nil
            ),
            ImageStub(
                description: nil,
                location: "Taj Mahal, India",
                image: nil
            ),
        ]
    }

    private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail(
                "Failed to load stored snapshot at url: \(snapshotURL). Use the 'record' method to store a snapshot before asserting.",
                file: file,
                line: line
            )
            return
        }

        if snapshotData != storedSnapshotData {
            let failedSnapshotsDirectory = URL(fileURLWithPath: String(describing: file))
                .deletingLastPathComponent()
                .appendingPathComponent("failed_snapshots")
            
            try? FileManager.default.createDirectory(at: failedSnapshotsDirectory, withIntermediateDirectories: true)
            
            let temporarySnapshotURL = URL(fileURLWithPath: failedSnapshotsDirectory.absoluteString, isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)

            try? snapshotData?.write(to: temporarySnapshotURL)

            XCTFail(
                "New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)",
                file: file,
                line: line
            )
        }
    }

    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }

    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }

        return data
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let rendered = UIGraphicsImageRenderer(bounds: view.bounds)
        return rendered.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells = stubs.map { stub -> FeedImageCellController in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?

    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(
            description: description,
            location: location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )
    }

    func didRequestImage() {
        controller?.display(viewModel)
    }

    func didCancelImageRequest() {}
}
