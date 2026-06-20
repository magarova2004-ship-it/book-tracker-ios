import SwiftUI

struct LibraryView: View {
    @Binding var books: [Book]
    @EnvironmentObject var settings: AppSettings
    private var currentlyReading: Book? {
        books.first(where: { $0.status == .reading })
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "books.vertical")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(Color(.systemGray3))
            Text("Твоя библиотека пуста")
                .font(.title3).bold()
            Text("Используй поиск, чтобы найти\nи добавить свои любимые книги")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }

    var body: some View {
        NavigationStack {
            Group {
                if books.isEmpty {
                    emptyStateView
                } else {
                    List {
                        if let book = currentlyReading {
                            Section {
                                CurrentlyReadingCard(book: book)
                                    .overlay {
                                        NavigationLink(destination: BookDetailView(allBooks: $books, book: book)) {}
                                            .opacity(0)
                                    }
                            } header: {
                                Label("Сейчас читаю", systemImage: "book.open.fill")
                                    .foregroundColor(.blue)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }

                        Section {
                            ForEach(books, id: \.id) { book in
                                BookCard(book: book)
                                    .overlay {
                                        NavigationLink(destination: BookDetailView(allBooks: $books, book: book)) {}
                                            .opacity(0)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            }
                            .onDelete { books.remove(atOffsets: $0) }
                        } header: {
                            Text("Вся библиотека")
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Привет, \(settings.userName)!")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct CurrentlyReadingCard: View {
    let book: Book

    var body: some View {
        HStack(spacing: 16) {
            BookCover(url: book.coverURL, width: 72, height: 100)
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 8) {
                Label("Читаю сейчас", systemImage: "book.open.fill")
                    .font(.caption).bold()
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())

                Text(book.title)
                    .font(.headline).bold().lineLimit(2)
                Text(book.author)
                    .font(.subheadline).foregroundColor(.secondary)

                ProgressView(value: Double(book.currentPage),
                             total: Double(max(book.pageCount, 1)))
                    .tint(.blue)
                Text("\(Int(book.progressPercentage))% · \(book.currentPage) из \(book.pageCount) стр.")
                    .font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.08), Color.indigo.opacity(0.05)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.blue.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.blue.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

private struct BookCard: View {
    let book: Book

    private var statusColor: Color { book.status == .reading ? .blue : .green }

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
                    Text(book.status.rawValue)
                        .font(.caption).bold()
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(statusColor.opacity(0.12))
                        .foregroundColor(statusColor)
                        .clipShape(Capsule())

                    if book.status == .reading && book.pageCount > 0 {
                        Text("\(Int(book.progressPercentage))%")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }

                if book.status == .reading && book.pageCount > 0 {
                    ProgressView(value: Double(book.currentPage),
                                 total: Double(book.pageCount))
                        .tint(statusColor)
                        .scaleEffect(x: 1, y: 0.8)
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
    }
}

struct BookCover: View {
    let url: String?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Group {
            if let urlString = url, let imageURL = URL(string: urlString) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(.systemGray5), Color(.systemGray4)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "book.closed.fill")
                    .font(.system(size: width * 0.32))
                    .foregroundColor(Color(.systemGray2))
            )
    }
}
