//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import EssentialFeediOS
import XCTest

final class ListSnapshotTests: XCTestCase {
    func test_emptyList() {
        let sut = makeSUT()

        sut.display(emptyList())

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "EMPTY_LIST_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "EMPTY_LIST_DARK")
    }

    func test_listwithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_LIGHT")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_DARK")
        assert(
            snapshot: sut.snapshot(for: .iPhone12Mini(style: .light, contentSize: .extraExtraExtraLarge)),
            named: "LIST_WITH_ERROR_MESSAGE_LIGHT_extraExtraExtraLarge"
        )
    }

    // MARK: - Helpers

    func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.loadViewIfNeeded()
        return controller
    }

    private func emptyList() -> [CellController] {
        []
    }
}
