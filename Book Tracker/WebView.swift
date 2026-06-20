import SwiftUI

struct WebView: View {
    let urlString: String
    @Binding var currentPage: Int
    let maxPreviewPages: Int
    var onLimitReached: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings

    @State private var pages: [String] = []
    @State private var isLoading = true
    @State private var loadError = false

    private var totalPages: Int {
        min(pages.count, maxPreviewPages)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            progressBar
            content
        }
        .task {
            await loadPages()
        }
    }

    private var topBar: some View {
        HStack {
            Button("Закрыть") { dismiss() }
                .padding()

            Spacer()

            VStack(spacing: 2) {
                if !isLoading && !pages.isEmpty {
                    Text("Стр. \(currentPage) из \(totalPages)")
                        .font(.subheadline)
                        .bold()
                }
                Text("Бесплатный фрагмент")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }

            Spacer()

            HStack(spacing: 0) {
                Button(action: prevPage) {
                    Image(systemName: "arrow.left")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                }
                .disabled(currentPage <= 1 || isLoading)

                Button(action: nextPage) {
                    HStack(spacing: 4) {
                        Text(currentPage >= totalPages ? "Конец" : "Дальше")
                            .bold()
                        if currentPage < totalPages {
                            Image(systemName: "arrow.right")
                        }
                    }
                    .foregroundColor(currentPage >= totalPages ? .gray : .blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                .disabled(isLoading)
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }

    private var progressBar: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(Color.orange)
                .frame(
                    width: totalPages > 0
                        ? geo.size.width * (Double(currentPage) / Double(totalPages))
                        : 0,
                    height: 3
                )
                .animation(.easeInOut, value: currentPage)
        }
        .frame(height: 3)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            VStack(spacing: 16) {
                ProgressView().scaleEffect(1.5)
                Text("Загружаем книгу...")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if loadError || pages.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                Text("Не удалось загрузить текст")
                    .font(.headline)
                Text("Текст этой книги недоступен")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            let pageIndex = currentPage - 1
            ScrollView {
                if pageIndex >= 0 && pageIndex < pages.count {
                    Text(pages[pageIndex])
                        .font(settings.readerFontSize.font)
                        .lineSpacing(settings.readerFontSize.lineSpacing)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .id(currentPage)
        }
    }

    private func prevPage() {
        guard currentPage > 1 else { return }
        currentPage -= 1
    }

    private func nextPage() {
        if currentPage < totalPages {
            currentPage += 1
        } else {
            onLimitReached()
        }
    }

    private func loadPages() async {
        let loaded = await NetworkManager.shared.fetchBookText(
            textURL: urlString,
            charsPerPage: 1800,
            maxPages: maxPreviewPages
        )
        await MainActor.run {
            pages = loaded
            isLoading = false
            loadError = loaded.isEmpty
        }
    }
}
