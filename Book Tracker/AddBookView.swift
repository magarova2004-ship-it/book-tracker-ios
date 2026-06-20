import SwiftUI

struct AddBookView: View {
    @Binding var books: [Book]
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var description: String = ""
    @State private var pageCountString: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Информация о книге")) {
                    TextField("Название", text: $title)
                    TextField("Автор", text: $author)
                    TextField("Описание", text: $description)
                    TextField("Количество страниц", text: $pageCountString)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Новая книга")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        if let pages = Int(pageCountString), !title.isEmpty {
                            let newBook = Book(
                                id: UUID().uuidString,
                                title: title,
                                author: author,
                                description: description,
                                pageCount: pages,
                                status: .reading,
                                currentPage: 0
                            )
                            books.append(newBook)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddBookView(books: .constant([]))
}
