import Testing
@testable import ComicPull

@Suite("Comic Model Tests")
struct ComicTests {
    @Test("Display title with series")
    func displayTitleWithSeries() {
        let series = Series(comicVineID: 1, name: "Batman", publisher: "DC Comics")
        let comic = Comic(comicVineID: 100, issueNumber: "5")
        comic.series = series

        #expect(comic.displayTitle == "Batman #5")
    }

    @Test("Display title without series falls back to title")
    func displayTitleFallback() {
        let comic = Comic(comicVineID: 100, issueNumber: "5", title: "Special Issue")
        #expect(comic.displayTitle == "Special Issue")
    }

    @Test("Display title no series no title")
    func displayTitleNoInfo() {
        let comic = Comic(comicVineID: 100, issueNumber: "5")
        #expect(comic.displayTitle == "#5")
    }
}

@Suite("Reading Status Tests")
struct ReadingStatusTests {
    @Test("All cases have system image")
    func allCasesHaveImage() {
        for status in ReadingStatus.allCases {
            #expect(!status.systemImage.isEmpty)
        }
    }

    @Test("Raw values are display friendly")
    func rawValues() {
        #expect(ReadingStatus.want.rawValue == "Want")
        #expect(ReadingStatus.acquired.rawValue == "Acquired")
        #expect(ReadingStatus.reading.rawValue == "Reading")
        #expect(ReadingStatus.read.rawValue == "Read")
    }
}

@Suite("User Review Tests")
struct UserReviewTests {
    @Test("Score is clamped 1-10")
    func scoreClamped() {
        let lowReview = UserReview(score: 0)
        #expect(lowReview.score == 1)

        let highReview = UserReview(score: 15)
        #expect(highReview.score == 10)

        let normalReview = UserReview(score: 7)
        #expect(normalReview.score == 7)
    }
}
