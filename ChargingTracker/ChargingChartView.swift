import SwiftUI

struct ChargingChartView: View {
    @ObservedObject var chargingData: ChargingData
    var selectedCarName: String
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                // 每個充電店家的充電次數
                VStack {
                    Text("每個充電店家的充電次數")
                        .font(.headline)
                        .padding(.top)
                    BarChartView(data: calculateStoreChargingCounts().mapValues { Double($0) }, title: "充電次數")
                        .padding()
                }
                .tag(0)
                .tabItem {
                    Text("充電次數")
                }
                
                // 每個充電店家已充電電力的加總
                VStack {
                    Text("每個充電店家的已充電電力")
                        .font(.headline)
                        .padding(.top)
                    BarChartView(data: calculateStoreChargingKWh(), title: "充電電力 (kWh)")
                        .padding()
                }
                .tag(1)
                .tabItem {
                    Text("充電電力")
                }
                
                // 每週充電花費金額
                VStack {
                    Text("每週充電花費金額")
                        .font(.headline)
                        .padding(.top)
                    BarChartView(data: calculateWeeklyTotalCost(), title: "總花費")
                        .padding()
                }
                .tag(2)
                .tabItem {
                    Text("總花費")
                }
                
                // 每週充電總電量
                VStack {
                    Text("每週充電總電量")
                        .font(.headline)
                        .padding(.top)
                    BarChartView(data: calculateWeeklyTotalKWh(), title: "總電量 (kWh)")
                        .padding()
                }
                .tag(3)
                .tabItem {
                    Text("總電量")
                }
                
                // 所有充電電量的總和
                VStack {
                    Text("所有充電電量的總和")
                        .font(.headline)
                        .padding(.top)
                    Text("\(calculateTotalChargingKWh(), specifier: "%.2f") kWh")
                        .font(.headline)
                        .padding()
                }
                .tag(4)
                .tabItem {
                    Text("總電量合計")
                }
                
                // 平均每次充電花費
                VStack {
                    Text("平均每次充電花費")
                        .font(.headline)
                        .padding(.top)
                    Text("\(calculateAverageCost(), specifier: "%.2f")")
                        .font(.headline)
                        .padding()
                }
                .tag(5)
                .tabItem {
                    Text("平均花費")
                }
                
                // 平均每次充電電量
                VStack {
                    Text("平均每次充電電量")
                        .font(.headline)
                        .padding(.top)
                    Text("\(calculateAverageKWh(), specifier: "%.2f") kWh")
                        .font(.headline)
                        .padding()
                }
                .tag(6)
                .tabItem {
                    Text("平均電量")
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            // 頁面指示器
            HStack {
                Text("頁面 \(selectedTab + 1) / 7")
                    .padding()
                Spacer()
            }
        }
    }
    
    private func filterRecordsByCarName(records: [ChargingRecord], carName: String) -> [ChargingRecord] {
        return records.filter { $0.carName == carName }
    }
    
    private func calculateStoreChargingCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        let filteredRecords = filterRecordsByCarName(records: chargingData.records, carName: selectedCarName)
        for record in filteredRecords {
            counts[record.storeName, default: 0] += 1
        }
        return counts
    }
    
    private func calculateStoreChargingKWh() -> [String: Double] {
        var totals: [String: Double] = [:]
        let filteredRecords = filterRecordsByCarName(records: chargingData.records, carName: selectedCarName)
        for record in filteredRecords {
            totals[record.storeName, default: 0] += record.kWh
        }
        return totals
    }
    
    private func calculateTotalChargingKWh() -> Double {
        let filteredRecords = filterRecordsByCarName(records: chargingData.records, carName: selectedCarName)
        return filteredRecords.reduce(0) { $0 + $1.kWh }
    }
    
    private func calculateWeeklyTotalCost() -> [String: Double] {
        var weeklyTotals: [String: Double] = [:]
        let filteredRecords = filterRecordsByCarName(records: chargingData.records, carName: selectedCarName)
        let calendar = Calendar.current
        for record in filteredRecords {
            let weekOfYear = calendar.component(.weekOfYear, from: record.date)
            let year = calendar.component(.year, from: record.date)
            let weekKey = "\(year)-W\(weekOfYear)"
            weeklyTotals[weekKey, default: 0] += record.totalCost
        }
        return weeklyTotals
    }
    
    private func calculateWeeklyTotalKWh() -> [String: Double] {
        var weeklyTotals: [String: Double] = [:]
        let filteredRecords = filterRecordsByCarName(records: chargingData.records, carName: selectedCarName)
        let calendar = Calendar.current
        for record in filteredRecords {
            let weekOfYear = calendar.component(.weekOfYear, from: record.date)
            let year = calendar.component(.year, from: record.date)
            let weekKey = "\(year)-W\(weekOfYear)"
            weeklyTotals[weekKey, default: 0] += record.kWh
        }
        return weeklyTotals
    }
    
    private func calculateAverageCost() -> Double {
        let filteredRecords = filterRecordsByCarName(records: chargingData.records, carName: selectedCarName)
        guard !filteredRecords.isEmpty else { return 0 }
        let totalCost = filteredRecords.reduce(0) { $0 + $1.totalCost }
        return totalCost / Double(filteredRecords.count)
    }
    
    private func calculateAverageKWh() -> Double {
        let filteredRecords = filterRecordsByCarName(records: chargingData.records, carName: selectedCarName)
        guard !filteredRecords.isEmpty else { return 0 }
        let totalKWh = filteredRecords.reduce(0) { $0 + $1.kWh }
        return totalKWh / Double(filteredRecords.count)
    }
}

