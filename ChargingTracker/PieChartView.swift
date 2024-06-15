import SwiftUI

struct PieChartView: View {
    var data: [String: Double]
    var title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 10)
            
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        ForEach(Array(data.keys.enumerated()), id: \.offset) { index, key in
                            PieSliceView(startAngle: angle(at: index), endAngle: angle(at: index + 1))
                                .fill(color(at: index))
                                .shadow(radius: 5)
                                .overlay(
                                    PieSliceView(startAngle: angle(at: index), endAngle: angle(at: index + 1))
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                    .frame(width: min(geometry.size.width * 0.8, geometry.size.height * 0.8), height: min(geometry.size.width * 0.8, geometry.size.height * 0.8))
                    .padding(.horizontal)
                    
                    let columns = [GridItem(.adaptive(minimum: 80))]
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        ForEach(Array(data.keys.enumerated()), id: \.offset) { index, key in
                            HStack {
                                color(at: index)
                                    .frame(width: 20, height: 20)
                                    .cornerRadius(5)
                                Text("\(key) (\(String(format: "%.0f", data[key]!)))")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .frame(width: geometry.size.width, alignment: .center)
                .padding(.bottom, 10) // 為了防止內容過多，增加底部填充
            }
            .frame(height: 300) // 調整此處高度以保持圖表和標籤在限定高度內
        }
        .padding(.horizontal)
        .frame(maxHeight: 400) // 確保總高度不超過
    }
    
    private func angle(at index: Int) -> Angle {
        let sum = data.values.reduce(0, +)
        let value = data.values.prefix(index).reduce(0, +)
        return .degrees(360 * value / sum)
    }
    
    private func color(at index: Int) -> Color {
        let colors: [Color] = [
            .blue.opacity(0.7), .green.opacity(0.7), .orange.opacity(0.7),
            .purple.opacity(0.7), .pink.opacity(0.7), .yellow.opacity(0.7),
            .gray.opacity(0.7), .cyan.opacity(0.7), .indigo.opacity(0.7)
        ]
        return colors[index % colors.count]
    }
}

struct PieSliceView: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}

