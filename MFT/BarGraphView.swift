import SwiftUI

struct BarGraphView: View {
    var stepsData: [Date: Double]
    var caloriesData: [Date: Double]
    var title: String
    
    private var maxValue: Double {
        max(stepsData.values.max() ?? 0, caloriesData.values.max() ?? 0)
    }
    
    private var sortedDates: [Date] {
        Array(Set(stepsData.keys).union(caloriesData.keys)).sorted()
    }
    
    private var globalMaxValue: Double {
         max(stepsData.values.max() ?? 0, caloriesData.values.max() ?? 0)
     }

    
    var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(sortedDates, id: \.self) { date in
                        VStack {
                            HStack(spacing: 2) {
                                // Pass the global max value for both bars
                                BarView(value: stepsData[date, default: 0], color: .blue, maxValue: globalMaxValue)
                                BarView(value: caloriesData[date, default: 0], color: .red, maxValue: globalMaxValue)
                            }
                            .frame(height: 200) // Ensure bars are within this frame
                            Text("\(date, formatter: dateFormatter)")
                                .font(.caption)
                        }
                    }
                }
                .padding(.top, 8) // Add some space at the top of the graph
            }
        }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }
}

struct BarView: View {
    var value: Double
    var color: Color
    var maxValue: Double
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 10, height: normalizedHeight(for: value, maxValue: maxValue)) // Adjust width as needed
    }
    
    private func normalizedHeight(for value: Double, maxValue: Double) -> CGFloat {
        // Normalize height calculation based on the maximum value in the dataset
        let graphHeight: CGFloat = 200 // Adjust as needed
        return CGFloat(value / (maxValue == 0 ? 1 : maxValue)) * graphHeight
    }
}
