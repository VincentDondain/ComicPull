import SwiftUI

actor ImageCache {
    static let shared = ImageCache()

    private var cache: [URL: Data] = [:]
    private let maxCacheSize = 100

    func data(for url: URL) -> Data? {
        cache[url]
    }

    func store(_ data: Data, for url: URL) {
        if cache.count >= maxCacheSize {
            cache.removeAll()
        }
        cache[url] = data
    }
}
