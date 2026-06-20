import SwiftUI

private let savedBooksKey = "saved_books"

private func loadSavedBooks() -> [Book] {
    guard let data = UserDefaults.standard.data(forKey: savedBooksKey),
          let books = try? JSONDecoder().decode([Book].self, from: data) else {
        return []
    }
    return books
}

struct ContentView: View {
    @StateObject private var settings = AppSettings()
    @State private var books: [Book] = loadSavedBooks()

    var body: some View {
        TabView {
            LibraryView(books: $books)
                .tabItem { Label("Библиотека", systemImage: "books.vertical.fill") }

            SearchView(allBooks: $books)
                .tabItem { Label("Поиск", systemImage: "magnifyingglass") }

            ProfileView(books: books)
                .tabItem { Label("Профиль", systemImage: "person.circle.fill") }
        }
        .environmentObject(settings)
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        .onChange(of: books) { _, newBooks in
            if let data = try? JSONEncoder().encode(newBooks) {
                UserDefaults.standard.set(data, forKey: savedBooksKey)
            }
        }
    }
}

#Preview { ContentView() }
