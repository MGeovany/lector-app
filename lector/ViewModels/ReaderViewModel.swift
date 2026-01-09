import Combine
import Foundation

@MainActor
final class ReaderViewModel: ObservableObject {
    @Published private(set) var pages: [String] = []
    @Published var currentIndex: Int = 0

    func setPages(_ newPages: [String], initialPage: Int?) {
        pages = newPages.isEmpty ? [""] : newPages

        let desiredIndex: Int = {
            if let initialPage {
                return max(0, initialPage - 1)
            }
            return currentIndex
        }()
        currentIndex = min(max(0, desiredIndex), max(0, pages.count - 1))
    }

    func goToPreviousPage() {
        currentIndex = max(0, currentIndex - 1)
    }

    func goToNextPage() {
        currentIndex = min(max(0, pages.count - 1), currentIndex + 1)
    }
}
