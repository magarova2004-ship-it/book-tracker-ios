//
//  BookDetailView.swift
//  Book Tracker
//

import SwiftUI

struct BookDetailView: View {
    @Binding var allBooks: [Book]
    @State var book: Book

    @State private var isShowingPreview = false
    @State private var isShowingBuySheet = false
    @State private var localPreviewPage = 1

    private var isAlreadySaved: Bool {
        allBooks.contains(where: { $0.id == book.id })
    }

    private var previewPages: Int {
        book.previewPageCount ?? 15
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeader
                contentCard
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $isShowingPreview) {
            if let urlString = book.previewURL {
                WebView(
                    urlString: urlString,
                    currentPage: $localPreviewPage,
                    maxPreviewPages: previewPages,
                    onLimitReached: {
                        isShowingPreview = false
                        isShowingBuySheet = true
                    }
                )
            }
        }
        .sheet(isPresented: $isShowingBuySheet) {
            BuySheet(bookTitle: book.title, onDismiss: { isShowingBuySheet = false })
        }
    }

    private var heroHeader: some View {
        ZStack(alignment: .center) {
            LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.35, blue: 0.82),
                    Color(red: 0.42, green: 0.18, blue: 0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 300)

            VStack(spacing: 0) {
                Spacer().frame(height: 56) // nav bar clearance
                BookCover(url: book.coverURL, width: 118, height: 162)
                    .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 10)
                Spacer().frame(height: 40)
            }
        }
    }


    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.title2).bold().lineLimit(3)
                Text(book.author)
                    .font(.subheadline).foregroundColor(.secondary)

                HStack(spacing: 8) {
                    MetaChip(icon: "book.pages", text: "\(book.pageCount) стр.")
                    if book.previewURL != nil {
                        MetaChip(icon: "eye.fill",
                                 text: "\(previewPages) стр. бесплатно",
                                 color: .orange)
                    }
                }
                .padding(.top, 4)
            }

            if isAlreadySaved {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Твой прогресс")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(book.progressPercentage))%")
                            .font(.headline).foregroundColor(.blue)
                    }
                    ProgressView(value: Double(book.currentPage),
                                 total: Double(max(book.pageCount, 1)))
                        .tint(.blue)
                        .scaleEffect(x: 1, y: 1.4)
                    Text("\(book.currentPage) из \(book.pageCount) стр.")
                        .font(.caption).foregroundColor(.secondary)
                }
                .padding(14)
                .background(Color.blue.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                )
            }

            if !book.description.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("О книге")
                        .font(.headline)
                    Text(book.description)
                        .font(.body).foregroundColor(.secondary)
                        .lineSpacing(4)
                }
            }

            VStack(spacing: 12) {
                if book.previewURL != nil {
                    ActionButton(
                        title: "Читать бесплатно (\(previewPages) стр.)",
                        icon: "book.pages.fill",
                        gradient: [.orange, Color(red: 1, green: 0.45, blue: 0.1)]
                    ) {
                        localPreviewPage = 1
                        isShowingPreview = true
                    }
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                        Text("Текст недоступен")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray5))
                    .foregroundColor(Color(.systemGray))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                // Mark progress / add to library
                ActionButton(
                    title: isAlreadySaved ? "Отметить +10 стр. прочитанными" : "Добавить в мои книги",
                    icon: isAlreadySaved ? "plus.circle.fill" : "books.vertical.fill",
                    gradient: isAlreadySaved ? [.blue, .indigo] : [.green, Color(red: 0.1, green: 0.7, blue: 0.4)]
                ) {
                    markProgress()
                }

                // Apple Books
                Button(action: openAppleBooks) {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Купить в Apple Books").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(.primary)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
            }
        }
        .padding(20)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .padding(.top, -28)
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -4)
    }

    // MARK: - Actions

    private func openAppleBooks() {
        let q = book.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://books.apple.com/search?term=\(q)") {
            UIApplication.shared.open(url)
        }
    }

    private func markProgress() {
        let newPage = min(book.currentPage + 10, book.pageCount)
        book.currentPage = newPage
        if let idx = allBooks.firstIndex(where: { $0.id == book.id }) {
            allBooks[idx].currentPage = newPage
        } else {
            allBooks.append(book)
        }
    }
}

// MARK: - Meta Chip

private struct MetaChip: View {
    let icon: String
    let text: String
    var color: Color = .secondary

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption).bold()
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

// MARK: - Action Button

private struct ActionButton: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title).bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: gradient,
                               startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: gradient.first?.opacity(0.35) ?? .clear, radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Buy Sheet

private struct BuySheet: View {
    let bookTitle: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Icon header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.12))
                        .frame(width: 88, height: 88)
                    Image(systemName: "lock.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .red.opacity(0.8)],
                                           startPoint: .top, endPoint: .bottom)
                        )
                }
                .padding(.top, 28)

                Text("Фрагмент закончился")
                    .font(.title3).bold()
                Text("Вы прочитали весь доступный фрагмент книги «\(bookTitle)».")
                    .font(.subheadline).foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Divider().padding(.vertical, 20)

            VStack(spacing: 12) {
                Button {
                    let q = bookTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "https://books.apple.com/search?term=\(q)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                        Text("Купить в Apple Books").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundColor(.primary)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
                BuySheetButton(title: "Найти в интернете", icon: "safari",
                               gradient: [.blue, .indigo]) {
                    let q = bookTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "https://www.google.com/search?q=\(q)+купить+книгу") {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Закрыть", action: onDismiss)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 20)
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(28)
    }
}

private struct BuySheetButton: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title).bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(LinearGradient(colors: gradient,
                                       startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

#Preview {
    NavigationStack {
        BookDetailView(
            allBooks: .constant([]),
            book: Book(
                id: "1", title: "Harry Potter and the Philosopher's Stone",
                author: "J.K. Rowling",
                description: "A story about a young wizard discovering his magical heritage.",
                pageCount: 400, status: .reading, currentPage: 120,
                previewURL: nil, previewPageCount: 40
            )
        )
    }
}
