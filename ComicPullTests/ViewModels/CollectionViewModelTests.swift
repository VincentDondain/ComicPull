import Testing
@testable import ComicPull

@Suite("Collection ViewModel Tests")
struct CollectionViewModelTests {
    @Test("Filter by status")
    func filterByStatus() {
        let vm = CollectionViewModel()

        let comic1 = Comic(comicVineID: 1, issueNumber: "1")
        comic1.status = .read

        let comic2 = Comic(comicVineID: 2, issueNumber: "2")
        comic2.status = .want

        vm.filterStatus = .read
        let filtered = vm.filteredComics(from: [comic1, comic2])
        #expect(filtered.count == 1)
        #expect(filtered.first?.comicVineID == 1)
    }

    @Test("No filter returns all")
    func noFilter() {
        let vm = CollectionViewModel()
        let comics = [
            Comic(comicVineID: 1, issueNumber: "1"),
            Comic(comicVineID: 2, issueNumber: "2")
        ]

        let result = vm.filteredComics(from: comics)
        #expect(result.count == 2)
    }
}
