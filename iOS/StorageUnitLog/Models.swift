import Foundation

struct BoxEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var contents: String
    var notes: String = ""
    var createdAt: Date = Date()
}
