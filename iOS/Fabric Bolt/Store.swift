import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Fabric] = []
    @Published var isPro: Bool = false

    static let freeLimit = 30

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("fabricbolt", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: Fabric) {
        guard canAddMore else { return }
        items.append(item)
        save()
    }

    func update(_ item: Fabric) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Fabric) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Fabric].self, from: data) {
            items = decoded
        } else {
            items = Store.seedData
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    static var seedData: [Fabric] {
        [
        Fabric(id: UUID(), title: "Liberty Lawn", printType: "Floral", yardage: 2.5, notes: "Tana lawn cotton"),
        Fabric(id: UUID(), title: "Quilting Cotton", printType: "Solid", yardage: 4.0, notes: "100% cotton"),
        Fabric(id: UUID(), title: "Linen Blend", printType: "Plain", yardage: 3.0, notes: "55/45 linen cotton")
        ]
    }
}
