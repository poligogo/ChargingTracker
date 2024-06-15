import SwiftUI

struct ChargingChartView: View {
    @ObservedObject var chargingData: ChargingData
    
    var body: some View {
        VStack {
            // 每個充電店家的充電次數
            Text("每個充電店家的充電次數")
                .font(.headline)
            BarChartView(data: calculateStoreChargingCounts().mapValues { Double($0) }, title: "充電次數")
                .frame(height: 300)
                .padding()
            
            // 每個充電店家已充電電力的加總
            Text("每個充電店家的已充電電力")
                .font(.headline)
            BarChartView(data: calculateStoreChargingKWh(), title: "充電電力 (kWh)")
                .frame(height: 300)
                .padding()
            
            // 所有充電電量的總和
            Text("所有充電電量的總和: \(calculateTotalChargingKWh(), specifier: "%.2f") kWh")
                .font(.headline)
                .padding()
        }
    }
    
    private func calculateStoreChargingCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        for record in chargingData.records {
            counts[record.storeName, default: 0] += 1
        }
        return counts
    }
    
    private func calculateStoreChargingKWh() -> [String: Double] {
        var totals: [String: Double] = [:]
        for record in chargingData.records {
            totals[record.storeName, default: 0] += record.kWh
        }
        return totals
    }
    
    private func calculateTotalChargingKWh() -> Double {
        return chargingData.records.reduce(0) { $0 + $1.kWh }
    }
}

struct BarChartView: View {
    var data: [String: Double]
    var title: String
    
    var body: some View {
        let sortedData = data.sorted { $0.key < $1.key }
        let maxValue = sortedData.map { $0.value }.max() ?? 1
        
        return GeometryReader { geometry in
            VStack {
                HStack(alignment: .bottom) {
                    ForEach(sortedData, id: \.key) { key, value in
                        VStack {
                            Text("\(value, specifier: "%.0f")")
                                .font(.caption)
                                .rotationEffect(.degrees(-45))
                                .offset(y: value == 0 ? 0 : -5)
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width / CGFloat(sortedData.count) * 0.8,
                                       height: CGFloat(value / maxValue) * geometry.size.height)
                            Text(key)
                                .font(.caption)
                                .rotationEffect(.degrees(-45))
                                .frame(width: geometry.size.width / CGFloat(sortedData.count) * 0.8)
                        }
                    }
                }
            }
        }
    }
}

