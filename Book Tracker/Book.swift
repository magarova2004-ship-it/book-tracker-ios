//
//  Book.swift
//  Book Tracker
//
//  Created by Alfiya on 13/6/26.
//

import Foundation

enum ReadingStatus: String, Codable {
    case reading = "Читаю"
    case finished = "Прочитано"
}

struct Book: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let author: String
    let description: String
    let pageCount: Int
    var status: ReadingStatus
    var currentPage: Int
    var previewURL: String?
    var previewPageCount: Int?
    var coverURL: String?

    var progressPercentage: Double {
        guard pageCount > 0 else { return 0.0 }
        return (Double(currentPage) / Double(pageCount)) * 100
    }
    
    init(id: String, title: String, author: String, description: String, pageCount: Int, status: ReadingStatus, currentPage: Int, previewURL: String? = nil, previewPageCount: Int? = nil, coverURL: String? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.pageCount = pageCount
        self.status = status
        self.currentPage = currentPage
        self.previewURL = previewURL
        self.previewPageCount = previewPageCount
        self.coverURL = coverURL
    }
}
