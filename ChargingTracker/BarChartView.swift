import SwiftUI

struct BarChartView: View {
    var data: [String: Double]
    var title: String
    
    var body: some View {
        let sortedData = data.sorted { $0.key < $1.key }
        let maxValue = sortedData.map { $0.value }.max() ?? 1
        
        return GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                }
                .padding(.bottom, 10)
                
                ForEach(sortedData, id: \.key) { key, value in
                    HStack {
                        Text(key)
                            .font(.caption)
                            .frame(width: geometry.size.width * 0.3, alignment: .leading) // 調整標籤的寬度
                        GeometryReader { innerGeometry in
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: barWidth(value: value, maxValue: maxValue, geometry: innerGeometry), height: 20) // 調整柱狀圖的寬度和高度
                        }
                        Text("\(value, specifier: "%.0f")")
                            .font(.caption)
                            .frame(width: geometry.size.width * 0.1, alignment: .trailing) // 顯示數值
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: CGFloat(data.count) * 40) // 調整整體高度
    }
    
    private func barWidth(value: Double, maxValue: Double, geometry: GeometryProxy) -> CGFloat {
        guard maxValue > 0, value >= 0, value.isFinite else {
            return 0
        }
        return CGFloat(value / maxValue) * (geometry.size.width * 0.6)
    }
}

