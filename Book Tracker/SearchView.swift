//
//  SearchView.swift
//  Book Tracker
//

import SwiftUI

enum SearchState {
    case idle
    case loading
    case results([Book])
    case empty
}

struct SearchView: View {
    @Binding var allBooks: [Book]
    @State private var searchText = ""
    @State private var searchState: SearchState = .idle

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                Group {
                    switch searchState {
                    case .idle:   idleView
                    case .loading: loadingView
                    case .results(let books): resultsList(books)
                    case .empty:  emptyView
                    }
                }
            }
            .navigationTitle("Поиск книг")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Название или автор...")
            .onChange(of: searchText) { _, newValue in
                guard !newValue.isEmpty else {
                    searchState = .idle
                    return
                }
                searchState = .loading
                let query = newValue
                Task {
                    let results = await NetworkManager.shared.searchBooks(query: query)
                    guard searchText == query else { return }
                    await MainActor.run {
                        searchState = results.isEmpty ? .empty : .results(results)
                    }
                }
            }
        }
    }

    // MARK: - States

    private var idleView: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.12), Color.purple.opacity(0.08)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 168, height: 168)

                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 68, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 10) {
                Text("Открой новую книгу")
                    .font(.title3).bold()
                Text("Ищи по названию, автору или жанру")
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            Text("Ищем книги...")
                .font(.subheadline).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.orange.opacity(0.7))
            }
            VStack(spacing: 8) {
                Text("Ничего не найдено")
                    .font(.title3).bold()
                Text("Попробуй изменить запрос или\nпоискать на другом языке")
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func resultsList(_ books: [Book]) -> some View {
        List(books, id: \.id) { book in
            SearchBookRow(book: book)
                .overlay {
                    NavigationLink(destination: BookDetailView(allBooks: $allBooks, book: book)) {}
                        .opacity(0)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Search Result Row

private struct SearchBookRow: View {
    let book: Book

    var body: some View {
        HStack(spacing: 14) {
            BookCover(url: book.coverURL, width: 52, height: 72)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.headline).bold().lineLimit(2)
                Text(book.author)
                    .font(.subheadline).foregroundColor(.secondary).lineLimit(1)

                HStack(spacing: 8) {
                    Label("\(book.pageCount) стр.", systemImage: "book")
                        .font(.caption).foregroundColor(.secondary)

                    if book.previewURL != nil {
                        Label("Фрагмент доступен", systemImage: "eye.fill")
                            .font(.caption).bold()
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.orange.opacity(0.12))
                            .foregroundColor(.orange)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
    }
}
