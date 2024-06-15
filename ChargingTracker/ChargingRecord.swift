import Foundation

struct ChargingRecord: Identifiable, Codable {
    var id = UUID()
    var carName: String
    var mileage: Double
    var date: Date
    var totalCost: Double
    var chargingTime: Double
    var storeName: String
    var station: String
    var kWh: Double
    
    var formattedKWh: String {
        return String(format: "%.3f", kWh / 1000)
    }
    
    var roundedCost: String {
        return String(format: "%.0f", totalCost.rounded())
    }
}

class ChargingData: ObservableObject {
    @Published var records: [ChargingRecord] = []
    
    private let fileName = "chargingData.json"
    
    init() {
        load()
    }
    
    func addRecord(_ record: ChargingRecord) {
        records.append(record)
        save()
    }
    
    func updateRecord(_ record: ChargingRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            save()
        }
    }
    
    func deleteRecord(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(records) {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            try? data.write(to: url)
        }
    }
    
    private func load() {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url),
           let savedRecords = try? JSONDecoder().decode([ChargingRecord].self, from: data) {
            records = savedRecords
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

