//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import EssentialFeed
import EssentialFeediOS
import XCTest

class FeedSnapshotTests: XCTestCase {
    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "feed_with_content_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "feed_with_content_dark")
        assert(
            snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)),
            named: "feed_with_content_light_extraExtraExtraLarge"
        )
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "feed_with_failed_image_loading_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "feed_with_failed_image_loading_dark")
        assert(
            snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)),
            named: "feed_with_failed_image_loading_light_extraExtraExtraLarge"
        )
    }

    // MARK: - Helpers

    func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.loadViewIfNeeded()
        return controller
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
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells = stubs.map { stub -> CellController in
            let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub)
            stub.controller = cellController
            return CellController(cellController)
        }
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel
    var image: UIImage?
    weak var controller: FeedImageCellController?

    init(description: String?, location: String?, image: UIImage?) {
        let extractedExpr = FeedImageViewModel(
            description: description,
            location: location
        )
        viewModel = extractedExpr
        self.image = image
    }

    func didRequestImage() {
        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any error"))
        }
    }

    func didCancelImageRequest() {}
}
