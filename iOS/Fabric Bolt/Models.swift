import Foundation

struct Fabric: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var printType: String
    var yardage: Double
    var notes: String
}
