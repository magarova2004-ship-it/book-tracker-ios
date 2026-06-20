import SwiftUI

struct ProfileView: View {
    let books: [Book]
    @EnvironmentObject var settings: AppSettings
    @State private var isEditingName = false

    private var readingCount: Int  { books.filter { $0.status == .reading }.count }
    private var finishedCount: Int { books.filter { $0.status == .finished }.count }
    private var totalPagesRead: Int { books.reduce(0) { $0 + $1.currentPage } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    gradientHeader
                    statsGrid
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    settingsCards
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var gradientHeader: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.20, blue: 0.85),
                    Color(red: 0.55, green: 0.15, blue: 0.80)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 240)

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 100, height: 100)
                    Image(systemName: "person.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle().stroke(.white.opacity(0.35), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)

                if isEditingName {
                    TextField("Твоё имя", text: $settings.userName)
                        .multilineTextAlignment(.center)
                        .font(.title3).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .padding(.horizontal, 48)
                        .submitLabel(.done)
                        .onSubmit { isEditingName = false }
                } else {
                    VStack(spacing: 4) {
                        Text(settings.userName)
                            .font(.title3).bold()
                            .foregroundColor(.white)
                        Button("Изменить имя") { isEditingName = true }
                            .font(.caption).foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            StatCard(icon: "book.fill",          color: .blue,   label: "Читаю",    value: "\(readingCount)")
            StatCard(icon: "checkmark.seal.fill", color: .green,  label: "Прочитано", value: "\(finishedCount)")
            StatCard(icon: "doc.text.fill",       color: .orange, label: "Страниц",  value: totalPagesRead.formatted())
            StatCard(icon: "books.vertical.fill", color: .purple, label: "Всего",    value: "\(books.count)")
        }
    }

    private var settingsCards: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Размер шрифта в ридере", systemImage: "textformat.size")
                    .font(.subheadline).bold()
                Picker("", selection: $settings.readerFontSize) {
                    ForEach(ReaderFontSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)

            HStack {
                Label("Тёмная тема", systemImage: "moon.fill")
                Spacer()
                Toggle("", isOn: $settings.isDarkMode)
                    .labelsHidden()
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
    }
}

private struct StatCard: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.title2).bold()
            Text(label)
                .font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: color.opacity(0.08), radius: 10, x: 0, y: 3)
    }
}

#Preview {
    ProfileView(books: [])
        .environmentObject(AppSettings())
}
