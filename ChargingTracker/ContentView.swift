import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var chargingData = ChargingData()
    @State private var newRecord = ChargingRecord(carName: "", mileage: 0, date: Date(), totalCost: 0, chargingTime: 0, storeName: "", station: "", kWh: 0)
    @State private var selectedRecord: ChargingRecord?
    @State private var showChart = false
    @State private var isVehicleSelected = false
    @State private var selectedCarName: String = ""

    @State private var showStoreNameAlert = false
    @State private var showStationAlert = false
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var availableStoreNames: [String] = []
    @State private var availableStations: [String] = []
    @State private var availableCarNames: [String] = []

    @State private var hours: String = ""
    @State private var minutes: String = ""
    @State private var showExportSheet = false
    @State private var exportData: Data?
    @State private var exportFilename: String = ""

    var body: some View {
        NavigationView {
            if !isVehicleSelected {
                VehicleSelectionView(selectedCarName: $selectedCarName, isVehicleSelected: $isVehicleSelected)
                    .background(Color(hex: "#F5F5F5"))
            } else {
                TabView {
                    // 新增充電記錄和充電記錄列表
                    VStack {
                        Form {
                            Section(header: Text("新增充電記錄").foregroundColor(Color(hex: "#333333"))) {
                                HStack {
                                    Text("車輛名稱: \(selectedCarName)").foregroundColor(Color(hex: "#333333"))
                                }
                                HStack {
                                    Text("現在里程:").foregroundColor(Color(hex: "#333333"))
                                    TextField("輸入現在里程", text: Binding(
                                        get: { newRecord.mileage == 0 ? "" : String(format: "%.0f", newRecord.mileage) },
                                        set: { newRecord.mileage = Double($0) ?? 0 }
                                    ))
                                    .keyboardType(.numberPad)
                                    .foregroundColor(Color(hex: "#333333"))
                                }
                                DatePicker("充電日期", selection: $newRecord.date, displayedComponents: .date)
                                    .foregroundColor(Color(hex: "#333333"))
                                HStack {
                                    Picker("充電方", selection: Binding(
                                        get: { newRecord.storeName.isEmpty ? "請選擇或新增店家" : newRecord.storeName },
                                        set: { newValue in
                                            if newValue == "請選擇或新增店家" {
                                                newRecord.storeName = ""
                                                showStoreNameAlert = true
                                            } else {
                                                newRecord.storeName = newValue
                                            }
                                        }
                                    )) {
                                        ForEach(availableStoreNames, id: \.self) { storeName in
                                            Text(storeName).tag(storeName)
                                        }
                                        Text("請選擇或新增店家").tag("請選擇或新增店家")
                                    }
                                    .foregroundColor(Color(hex: "#333333"))
                                }
                                .alert("輸入新的充電店家名稱", isPresented: $showStoreNameAlert, actions: {
                                    TextField("店家名稱", text: $newRecord.storeName)
                                    Button("確定") {
                                        if !newRecord.storeName.isEmpty {
                                            availableStoreNames.append(newRecord.storeName)
                                        }
                                    }
                                    Button("取消", role: .cancel) { }
                                })
                                
                                HStack {
                                    Picker("充電站", selection: Binding(
                                        get: { newRecord.station.isEmpty ? "請選擇或新增充電站" : newRecord.station },
                                        set: { newValue in
                                            if newValue == "請選擇或新增充電站" {
                                                newRecord.station = ""
                                                showStationAlert = true
                                            } else {
                                                newRecord.station = newValue
                                            }
                                        }
                                    )) {
                                        ForEach(availableStations, id: \.self) { station in
                                            Text(station).tag(station)
                                        }
                                        Text("請選擇或新增充電站").tag("請選擇或新增充電站")
                                    }
                                    .foregroundColor(Color(hex: "#333333"))
                                }
                                .alert("輸入新的充電站名稱", isPresented: $showStationAlert, actions: {
                                    TextField("充電站名稱", text: $newRecord.station)
                                    Button("確定") {
                                        if !newRecord.station.isEmpty {
                                            availableStations.append(newRecord.station)
                                        }
                                    }
                                    Button("取消", role: .cancel) { }
                                })
                                HStack {
                                    Text("充電總花費時間:").foregroundColor(Color(hex: "#333333"))
                                    HStack {
                                        TextField("小時", text: $hours)
                                            .keyboardType(.numberPad)
                                        Text("小時")
                                        TextField("分鐘", text: $minutes)
                                            .keyboardType(.numberPad)
                                        Text("分鐘")
                                    }
                                    .foregroundColor(Color(hex: "#333333"))
                                }
                                HStack {
                                    Text("充電電量 kWh:").foregroundColor(Color(hex: "#333333"))
                                    TextField("輸入充電電量 kWh", text: Binding(
                                        get: { newRecord.kWh == 0 ? "" : String(newRecord.kWh) },
                                        set: { newRecord.kWh = Double($0) ?? 0 }
                                    ))
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(Color(hex: "#333333"))
                                }
                                HStack {
                                    Text("總花費:").foregroundColor(Color(hex: "#333333"))
                                    TextField("輸入總花費", text: Binding(
                                        get: { newRecord.totalCost == 0 ? "" : String(newRecord.totalCost) },
                                        set: { newRecord.totalCost = Double($0) ?? 0 }
                                    ))
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(Color(hex: "#333333"))
                                }
                                Button(action: {
                                    if validateRecord() {
                                        newRecord.carName = selectedCarName
                                        newRecord.chargingTime = Double((Int(hours) ?? 0) * 60 + (Int(minutes) ?? 0))
                                        chargingData.addRecord(newRecord)
                                        availableStoreNames = Array(Set(chargingData.records.map { $0.storeName }))
                                        availableStations = Array(Set(chargingData.records.map { $0.station }))
                                        newRecord = ChargingRecord(carName: selectedCarName, mileage: 0, date: Date(), totalCost: 0, chargingTime: 0, storeName: "", station: "", kWh: 0)
                                        hours = ""
                                        minutes = ""
                                    }
                                }) {
                                    Text("新增記錄")
                                        .padding()
                                        .background(Color(hex: "#50E3C2"))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .alert(isPresented: $showValidationAlert) {
                                    Alert(title: Text("提示"), message: Text(validationMessage), dismissButton: .default(Text("確定")))
                                }
                            }
                            
                            Section(header: Text("充電記錄").foregroundColor(Color(hex: "#333333"))) {
                                List {
                                    ForEach(chargingData.records.filter { $0.carName == selectedCarName }) { record in
                                        NavigationLink(destination: RecordDetailView(record: record, chargingData: chargingData)) {
                                            ChargingRecordCard(record: record)
                                        }
                                    }
                                    .onDelete(perform: chargingData.deleteRecord)
                                }
                            }
                        }
                    }
                    .tabItem {
                        Image(systemName: "pencil.circle.fill")
                        Text("充電記錄")
                    }
                    
                    // 統計圖表
                    ChartView(chargingData: chargingData, selectedCarName: selectedCarName)
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("統計圖表")
                        }
                    
                    // 匯出資料
                    VStack {
                        Button(action: {
                            exportData = generateCSVData()
                            exportFilename = "\(selectedCarName)_charging_records.csv"
                            showExportSheet = true
                        }) {
                            Text("匯出資料")
                                .padding()
                                .background(Color(hex: "#50E3C2"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        .fileExporter(
                            isPresented: $showExportSheet,
                            document: CSVDocument(data: exportData ?? Data(), filename: exportFilename),
                            contentType: .commaSeparatedText,
                            defaultFilename: exportFilename
                        ) { result in
                            switch result {
                            case .success:
                                print("成功匯出")
                            case .failure(let error):
                                print("匯出失敗: \(error.localizedDescription)")
                            }
                        }
                    }
                    .tabItem {
                        Image(systemName: "square.and.arrow.up.fill")
                        Text("匯出資料")
                    }
                }
                .onAppear {
                    selectedCarName = UserDefaults.standard.string(forKey: "selectedCarName") ?? ""
                    availableStoreNames = Array(Set(chargingData.records.map { $0.storeName }))
                    availableStations = Array(Set(chargingData.records.map { $0.station }))
                    availableCarNames = Array(Set(chargingData.records.map { $0.carName }))
                }
                .background(Color(hex: "#F5F5F5"))
                .navigationBarBackButtonHidden(true) // 隱藏自動的返回按鈕
                .navigationBarItems(leading: Button(action: {
                    isVehicleSelected = false
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "#4A90E2"))
                    Text("選擇車輛")
                        .foregroundColor(Color(hex: "#4A90E2"))
                })
            }
        }
    }

    private func validateRecord() -> Bool {
        if selectedCarName.isEmpty {
            validationMessage = "請選擇車輛名稱。"
            showValidationAlert = true
            return false
        }
        if newRecord.mileage == 0 {
            validationMessage = "請輸入現在里程。"
            showValidationAlert = true
            return false
        }
        if newRecord.storeName.isEmpty {
            validationMessage = "請選擇或新增充電店家。"
            showValidationAlert = true
            return false
        }
        if newRecord.station.isEmpty {
            validationMessage = "請選擇或新增充電站。"
            showValidationAlert = true
            return false
        }
        if newRecord.kWh == 0 {
            validationMessage = "請輸入充電電量。"
            showValidationAlert = true
            return false
        }
        if newRecord.totalCost == 0 {
            validationMessage = "請輸入總花費。"
            showValidationAlert = true
            return false
        }
        return true
    }

    private func generateCSVData() -> Data {
        var csvString = "車輛名稱,現在里程,充電日期,總花費,充電總花費時間,充電店家,充電站,充電電量(kWh)\n"
        let records = chargingData.records.filter { $0.carName == selectedCarName }
        for record in records {
            let row = "\(record.carName),\(Int(record.mileage)),\(record.date),\(record.totalCost),\(String(format: "%02d:%02d", Int(record.chargingTime) / 60, Int(record.chargingTime) % 60)),\(record.storeName),\(record.station),\(record.kWh)\n"
            csvString += row
        }
        return csvString.data(using: .utf8) ?? Data()
    }
}

struct ChargingRecordCard: View {
    var record: ChargingRecord

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(record.storeName)
                        .font(.headline)
                    Text(record.station)
                        .font(.subheadline)
                }
                Spacer()
                VStack {
                    Text("\(record.date, formatter: dateFormatter)")
                        .font(.subheadline)
                    Text(String(format: "%.2f kWh", record.kWh))
                        .font(.headline)
                    Text("\(Int(record.totalCost)) 元")
                        .font(.subheadline)
                }
            }
            Divider()
        }
        .padding()
        .background(Color(hex: "#FFFFFF"))
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }
}

struct RecordDetailView: View {
    var record: ChargingRecord
    @ObservedObject var chargingData: ChargingData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("詳細資訊")
                    .font(.title)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("車輛名稱:")
                            .font(.headline)
                        Spacer()
                        Text(record.carName)
                            .font(.body)
                    }
                    HStack {
                        Text("里程:")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(record.mileage)) 公里")
                            .font(.body)
                    }
                    HStack {
                        Text("日期:")
                            .font(.headline)
                        Spacer()
                        Text(record.date, formatter: dateFormatter)
                            .font(.body)
                    }
                    HStack {
                        Text("總花費:")
                            .font(.headline)
                        Spacer()
                        Text("\(record.roundedCost) 元")
                            .font(.body)
                    }
                    HStack {
                        Text("充電總花費時間:")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%02d:%02d", Int(record.chargingTime) / 60, Int(record.chargingTime) % 60))
                            .font(.body)
                    }
                    HStack {
                        Text("充電店家:")
                            .font(.headline)
                        Spacer()
                        Text(record.storeName)
                            .font(.body)
                    }
                    HStack {
                        Text("充電站:")
                            .font(.headline)
                        Spacer()
                        Text(record.station)
                            .font(.body)
                    }
                    HStack {
                        Text("充電電量:")
                            .font(.headline)
                        Spacer()
                        Text("\(record.formattedKWh) kWh")
                            .font(.body)
                    }
                }
                .padding()
                .background(Color(hex: "#FFFFFF"))
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .padding()
            .navigationBarTitle("充電紀錄詳情", displayMode: .inline)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

struct ChartView: View {
    @ObservedObject var chargingData: ChargingData
    var selectedCarName: String

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(chartData(), id: \.title) { chart in
                    VStack(alignment: .leading) {
                        Text(chart.title)
                            .font(.headline)
                            .padding(.top)
                        if chart.title == "每個充電店家的充電次數" || chart.title == "每個充電店家的已充電電力" {
                            PieChartView(data: chart.data, title: chart.title)
                                .padding()
                        } else if chart.title == "每週充電花費金額" {
                            LineChartView(data: chart.lineData, title: chart.title)
                                .padding()
                        } else {
                            BarChartView(data: chart.data, title: chart.title)
                                .padding()
                        }
                    }
                    .padding()
                    .background(Color(hex: "#FFFFFF"))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }
            .padding()
        }
        .background(Color(hex: "#F5F5F5"))
        .navigationBarTitle("充電圖表", displayMode: .inline)
    }
    
    private func chartData() -> [(title: String, data: [String: Double], lineData: [Double])] {
        return [
            ("現在總里程", calculateCurrentTotalMileage().mapValues { Double($0) }, []),
            ("每度電行駛公里數", calculateKmPerKWh().mapValues { Double($0) }, []),
            ("每週充電總電量", calculateWeeklyTotalKWh(), []),
            ("每週充電花費金額", [:], calculateWeeklyTotalCostForLineChart()),
            ("每個充電店家的充電次數", calculateStoreChargingCounts().mapValues { Double($0) }, []),
            ("每個充電店家的已充電電力", calculateStoreChargingKWh(), [])
        ]
    }

    private func calculateStoreChargingCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        let filteredRecords = chargingData.records.filter { $0.carName == selectedCarName }
        for record in filteredRecords {
            counts[record.storeName, default: 0] += 1
        }
        return counts
    }
    
    private func calculateStoreChargingKWh() -> [String: Double] {
        var totals: [String: Double] = [:]
        let filteredRecords = chargingData.records.filter { $0.carName == selectedCarName }
        for record in filteredRecords {
            totals[record.storeName, default: 0] += record.kWh
        }
        return totals
    }

    private func calculateWeeklyTotalCost() -> [String: Double] {
        var weeklyTotals: [String: Double] = [:]
        let filteredRecords = chargingData.records.filter { $0.carName == selectedCarName }
        let calendar = Calendar.current
        for record in filteredRecords {
            let weekOfYear = calendar.component(.weekOfYear, from: record.date)
            let year = calendar.component(.year, from: record.date)
            let weekKey = "\(year)-W\(weekOfYear)"
            weeklyTotals[weekKey, default: 0] += record.totalCost
        }
        return weeklyTotals
    }
    
    private func calculateWeeklyTotalCostForLineChart() -> [Double] {
        let filteredRecords = chargingData.records.filter { $0.carName == selectedCarName }
        let calendar = Calendar.current
        var weeklyTotals: [Double] = Array(repeating: 0, count: 4) // 最多顯示四周
        
        for record in filteredRecords {
            let weekOfYear = calendar.component(.weekOfYear, from: record.date)
            let year = calendar.component(.year, from: record.date)
            let currentWeek = calendar.component(.weekOfYear, from: Date())
            let currentYear = calendar.component(.year, from: Date())
            
            let weekIndex = (currentYear - year) * 52 + (currentWeek - weekOfYear)
            if weekIndex >= 0 && weekIndex < 4 {
                weeklyTotals[weekIndex] += record.totalCost
            }
        }
        return weeklyTotals.reversed() // 反轉數據，從當前週顯示到四周前
    }

    private func calculateWeeklyTotalKWh() -> [String: Double] {
        var weeklyTotals: [String: Double] = [:]
        let filteredRecords = chargingData.records.filter { $0.carName == selectedCarName }
        let calendar = Calendar.current
        for record in filteredRecords {
            let weekOfYear = calendar.component(.weekOfYear, from: record.date)
            let year = calendar.component(.year, from: record.date)
            let weekKey = "\(year)-W\(weekOfYear)"
            weeklyTotals[weekKey, default: 0] += record.kWh
        }
        return weeklyTotals
    }

    private func calculateCurrentTotalMileage() -> [String: Int] {
        var totalMileage: [String: Int] = [:]
        let filteredRecords = chargingData.records.filter { $0.carName == selectedCarName }
        if let latestRecord = filteredRecords.max(by: { $0.date < $1.date }) {
            totalMileage[selectedCarName] = Int(latestRecord.mileage)
        }
        return totalMileage
    }

    private func calculateKmPerKWh() -> [String: Double] {
        var kmPerKWh: [String: Double] = [:]
        let filteredRecords = chargingData.records.filter { $0.carName == selectedCarName }
        let totalKWh = filteredRecords.reduce(0) { $0 + $1.kWh }
        if let latestRecord = filteredRecords.max(by: { $0.date < $1.date }), totalKWh > 0 {
            let totalMileage = latestRecord.mileage
            kmPerKWh[selectedCarName] = totalMileage / totalKWh
        }
        return kmPerKWh
    }
}




struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    var data: Data
    var filename: String

    init(data: Data, filename: String) {
        self.data = data
        self.filename = filename
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
        self.filename = "export.csv"
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = filename
        return fileWrapper
    }
}

// 用於 Hex 顏色轉換的擴展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

