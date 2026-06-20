import Foundation

struct OLSearchResponse: Codable {
    let docs: [OLDoc]?
}

struct OLDoc: Codable {
    let key: String
    let title: String
    let author_name: [String]?
    let number_of_pages_median: Int?
    let first_publish_year: Int?
    let subject: [String]?
    let cover_i: Int?
}

struct GutenbergResponse: Codable {
    let results: [GutenbergBook]?
}

struct GutenbergBook: Codable {
    let title: String
    let authors: [GutenbergAuthor]
    let formats: [String: String]
}

struct GutenbergAuthor: Codable {
    let name: String
}

class NetworkManager {
    static let shared = NetworkManager()

    func searchBooks(query: String) async -> [Book] {
        guard !query.isEmpty else { return [] }

        async let olTask = fetchOpenLibrary(query: query)
        async let gutTask = fetchGutenberg(query: query)
        let (olBooks, gutEntries) = await (olTask, gutTask)

        return olBooks.map { book in
            guard let match = gutEntries.first(where: { titlesMatch($0.title, book.title) }) else {
                return book
            }
            var enriched = book
            if let url = match.previewURL {
                enriched.previewURL = url
                enriched.previewPageCount = 40
            }
            if let cover = match.coverURL {
                enriched.coverURL = cover
            }
            return enriched
        }
    }

    private func fetchOpenLibrary(query: String) async -> [Book] {
        guard let encoded = query
            .trimmingCharacters(in: .whitespaces)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://openlibrary.org/search.json?q=\(encoded)&limit=20&fields=key,title,author_name,number_of_pages_median,first_publish_year,subject")
        else { return [] }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return [] }

            let decoded = try JSONDecoder().decode(OLSearchResponse.self, from: data)
            let docs = decoded.docs ?? []

            return docs.compactMap { doc -> Book? in
                guard !doc.title.isEmpty else { return nil }

                let author = doc.author_name?.first ?? "Неизвестный автор"
                let pages = max(doc.number_of_pages_median ?? 0, 50)

                var descParts: [String] = []
                if let year = doc.first_publish_year {
                    descParts.append("Впервые издана: \(year)")
                }
                if let subjects = doc.subject, !subjects.isEmpty {
                    descParts.append("Жанр: \(subjects.prefix(3).joined(separator: ", "))")
                }

                let coverURL = doc.cover_i.map { "https://covers.openlibrary.org/b/id/\($0)-M.jpg" }

                return Book(
                    id: UUID().uuidString,
                    title: doc.title,
                    author: author,
                    description: descParts.joined(separator: "\n"),
                    pageCount: pages,
                    status: .reading,
                    currentPage: 0,
                    coverURL: coverURL
                )
            }
        } catch {
            return []
        }
    }

    private struct GutEntry {
        let title: String
        let previewURL: String?
        let coverURL: String?
    }

    private func fetchGutenberg(query: String) async -> [GutEntry] {
        guard let encoded = query
            .trimmingCharacters(in: .whitespaces)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://gutendex.com/books/?search=\(encoded)")
        else { return [] }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return [] }

            let decoded = try JSONDecoder().decode(GutenbergResponse.self, from: data)
            let books = decoded.results ?? []

            return books.map { book in
                let textURL = book.formats["text/plain; charset=utf-8"]
                    ?? book.formats["text/plain; charset=us-ascii"]
                    ?? book.formats["text/plain"]
                let coverURL = book.formats["image/jpeg"]
                return GutEntry(title: book.title, previewURL: textURL, coverURL: coverURL)
            }
        } catch {
            return []
        }
    }

    private func titlesMatch(_ a: String, _ b: String) -> Bool {
        let norm: (String) -> String = {
            var s = $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            for article in ["the ", "a ", "an "] {
                if s.hasPrefix(article) { s = String(s.dropFirst(article.count)); break }
            }
            return s.components(separatedBy: .punctuationCharacters)
                    .joined(separator: " ")
                    .components(separatedBy: .whitespaces)
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
        }
        let na = norm(a)
        let nb = norm(b)
        if na == nb { return true }
        let shorter = na.count <= nb.count ? na : nb
        let longer  = na.count <= nb.count ? nb : na
        return shorter.count >= 6 && longer.contains(shorter)
    }

    func fetchBookText(textURL: String, charsPerPage: Int = 1800, maxPages: Int = 40) async -> [String] {
        let httpsURL = textURL.hasPrefix("http://")
            ? "https://" + textURL.dropFirst(7)
            : textURL
        guard let url = URL(string: httpsURL) else { return [] }

        var request = URLRequest(url: url, timeoutInterval: 30)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse {
                guard http.statusCode == 200 else { return [] }
            }

            var fullText = String(data: data, encoding: .utf8)
                ?? String(data: data, encoding: .isoLatin1)
                ?? String(data: data, encoding: .windowsCP1252)
                ?? ""

            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !trimmed.hasPrefix("<!doctype") && !trimmed.hasPrefix("<html") else {
                return []
            }

            if let startRange = fullText.range(of: "*** START OF") ?? fullText.range(of: "***START OF") {
                let after = fullText[startRange.upperBound...]
                if let lineEnd = after.range(of: "\n") {
                    fullText = String(after[lineEnd.upperBound...])
                }
            }

            if let endRange = fullText.range(of: "*** END OF") ?? fullText.range(of: "***END OF") {
                fullText = String(fullText[..<endRange.lowerBound])
            }

            fullText = fullText.trimmingCharacters(in: .whitespacesAndNewlines)

            var pages: [String] = []
            var index = fullText.startIndex

            while index < fullText.endIndex && pages.count < maxPages {
                let end = fullText.index(index, offsetBy: charsPerPage, limitedBy: fullText.endIndex) ?? fullText.endIndex
                var pageEnd = end
                if end < fullText.endIndex, let newline = fullText[end...].firstIndex(of: "\n") {
                    pageEnd = newline
                }
                let pageText = String(fullText[index..<pageEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !pageText.isEmpty { pages.append(pageText) }
                index = pageEnd
            }

            return pages

        } catch {
            return []
        }
    }
}
