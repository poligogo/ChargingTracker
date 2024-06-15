import SwiftUI

struct ContentView: View {
    @StateObject private var chargingData = ChargingData()
    @State private var newRecord = ChargingRecord(mileage: 0, date: Date(), totalCost: 0, chargingTime: 0, storeName: "", station: "", kWh: 0)
    @State private var selectedRecord: ChargingRecord?
    @State private var showChart = false

    @State private var showStoreNameAlert = false
    @State private var showStationAlert = false
    @State private var availableStoreNames: [String] = []
    @State private var availableStations: [String] = []

    var body: some View {
        VStack {
            Form {
                Section(header: Text("新增充電記錄")) {
                    HStack {
                        Text("現在里程:")
                        TextField("輸入現在里程", text: Binding(
                            get: { newRecord.mileage == 0 ? "" : String(newRecord.mileage) },
                            set: { newRecord.mileage = Double($0) ?? 0 }
                        ))
                        .keyboardType(.decimalPad)
                    }
                    DatePicker("充電日期", selection: $newRecord.date, displayedComponents: .date)
                    HStack {
                        Text("總花費:")
                        TextField("輸入總花費", text: Binding(
                            get: { newRecord.totalCost == 0 ? "" : String(newRecord.totalCost) },
                            set: { newRecord.totalCost = Double($0) ?? 0 }
                        ))
                        .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("充電總花費時間:")
                        TextField("輸入充電總花費時間", text: Binding(
                            get: { newRecord.chargingTime == 0 ? "" : String(newRecord.chargingTime) },
                            set: { newRecord.chargingTime = Double($0) ?? 0 }
                        ))
                        .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("選擇充電的店家:")
                        Picker("選擇充電的店家", selection: Binding(
                            get: { newRecord.storeName.isEmpty ? "新增新的店家" : newRecord.storeName },
                            set: { newValue in
                                if newValue == "新增新的店家" {
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
                            Text("新增新的店家").tag("新增新的店家")
                        }
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
                        Text("選擇充電站:")
                        Picker("選擇充電站", selection: Binding(
                            get: { newRecord.station.isEmpty ? "新增新的充電站" : newRecord.station },
                            set: { newValue in
                                if newValue == "新增新的充電站" {
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
                            Text("新增新的充電站").tag("新增新的充電站")
                        }
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
                        Text("充電電量 kWh:")
                        TextField("輸入充電電量 kWh", text: Binding(
                            get: { newRecord.kWh == 0 ? "" : String(newRecord.kWh) },
                            set: { newRecord.kWh = Double($0) ?? 0 }
                        ))
                        .keyboardType(.decimalPad)
                    }
                    
                    Button(action: {
                        chargingData.addRecord(newRecord)
                        availableStoreNames = Array(Set(chargingData.records.map { $0.storeName }))
                        availableStations = Array(Set(chargingData.records.map { $0.station }))
                        newRecord = ChargingRecord(mileage: 0, date: Date(), totalCost: 0, chargingTime: 0, storeName: "", station: "", kWh: 0)
                    }) {
                        Text("新增記錄")
                    }
                }
                
                Section(header: Text("充電記錄")) {
                    List {
                        ForEach(chargingData.records) { record in
                            VStack(alignment: .leading) {
                                Text("里程: \(record.mileage)")
                                Text("日期: \(record.date, formatter: dateFormatter)")
                                Text("總花費: \(record.roundedCost)")
                                Text("充電總花費時間: \(record.chargingTime)")
                                Text("充電店家: \(record.storeName)")
                                Text("充電站: \(record.station)")
                                Text("充電電量: \(record.formattedKWh) kWh")
                            }
                            .onTapGesture {
                                selectedRecord = record
                            }
                        }
                        .onDelete(perform: chargingData.deleteRecord)
                    }
                }
            }
            
            Button(action: {
                showChart.toggle()
            }) {
                Text(showChart ? "關閉圖表" : "顯示圖表")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            if showChart {
                ChargingChartView(chargingData: chargingData)
                    .frame(height: 300) // 調整圖表的高度
                    .transition(.slide)
            }
            
            if let selectedRecord = selectedRecord {
                RecordDetailView(record: selectedRecord, chargingData: chargingData)
            }
        }
        .onAppear {
            availableStoreNames = Array(Set(chargingData.records.map { $0.storeName }))
            availableStations = Array(Set(chargingData.records.map { $0.station }))
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

struct RecordDetailView: View {
    var record: ChargingRecord
    @ObservedObject var chargingData: ChargingData

    var body: some View {
        VStack {
            Text("詳細資訊")
            Text("里程: \(record.mileage)")
            Text("日期: \(record.date, formatter: dateFormatter)")
            Text("總花費: \(record.roundedCost)")
            Text("充電總花費時間: \(record.chargingTime)")
            Text("充電店家: \(record.storeName)")
            Text("充電站: \(record.station)")
            Text("充電電量: \(record.formattedKWh) kWh")
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

