import Testing
@testable import ComicPull

@Suite("Weekly Releases ViewModel Tests")
struct WeeklyReleasesViewModelTests {
    @Test("Load releases populates issues")
    @MainActor
    func loadReleases() async {
        let mockIssue = ComicVineIssue(
            id: 1,
            issueNumber: "1",
            name: "Batman",
            description: nil,
            storeDate: "2026-03-18",
            image: nil,
            volume: ComicVineVolume(id: 100, name: "Batman", publisher: ComicVinePublisher(id: 10, name: "DC Comics"), countOfIssues: 50),
            personCredits: nil
        )

        var service = MockComicVineService()
        service.issuesResult = .success([mockIssue])

        let vm = WeeklyReleasesViewModel(comicVineService: service)
        await vm.loadWeeklyReleases()

        #expect(vm.issues.count == 1)
        #expect(vm.isLoading == false)
        #expect(vm.error == nil)
    }

    @Test("Publisher filter works")
    @MainActor
    func publisherFilter() async {
        let dcIssue = ComicVineIssue(
            id: 1, issueNumber: "1", name: "Batman", description: nil, storeDate: nil, image: nil,
            volume: ComicVineVolume(id: 100, name: "Batman", publisher: ComicVinePublisher(id: 10, name: "DC Comics"), countOfIssues: 1),
            personCredits: nil
        )
        let marvelIssue = ComicVineIssue(
            id: 2, issueNumber: "1", name: "Spider-Man", description: nil, storeDate: nil, image: nil,
            volume: ComicVineVolume(id: 200, name: "Spider-Man", publisher: ComicVinePublisher(id: 20, name: "Marvel"), countOfIssues: 1),
            personCredits: nil
        )

        var service = MockComicVineService()
        service.issuesResult = .success([dcIssue, marvelIssue])

        let vm = WeeklyReleasesViewModel(comicVineService: service)
        await vm.loadWeeklyReleases()

        vm.selectedPublisher = "DC Comics"
        #expect(vm.filteredIssues.count == 1)
        #expect(vm.filteredIssues.first?.name == "Batman")
    }
}
