import SwiftUI

struct LineChartView: View {
    var data: [Double]
    var title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 10)
            
            GeometryReader { geometry in
                let maxValue = (data.max() ?? 1)
                let minValue = (data.min() ?? 0)
                let height = geometry.size.height
                let width = geometry.size.width / CGFloat(data.count - 1)
                
                ZStack {
                    // Draw the line
                    Path { path in
                        for index in data.indices {
                            let xPosition = CGFloat(index) * width
                            let yPosition = height - CGFloat((data[index] - minValue) / (maxValue - minValue)) * height
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: xPosition, y: yPosition))
                            } else {
                                path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                    .shadow(radius: 5)
                    
                    // Add the data points and labels
                    ForEach(data.indices, id: \.self) { index in
                        let xPosition = CGFloat(index) * width
                        let yPosition = height - CGFloat((data[index] - minValue) / (maxValue - minValue)) * height
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .position(x: xPosition, y: yPosition)
                        
                        Text(String(format: "%.0f", data[index]))
                            .font(.caption)
                            .foregroundColor(.black)
                            .position(x: xPosition, y: yPosition - 10)
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
    }
}
