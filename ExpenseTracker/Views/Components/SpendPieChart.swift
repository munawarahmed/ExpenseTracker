import SwiftUI
import Charts

// Category breakdown drawn with Apple's built-in Swift Charts library.
struct SpendPieChart: View {
    // Pre-aggregated data: one slice per category.
    let slices: [(category: String, total: Double, color: String, icon: String)]

    var body: some View {
        Chart(slices, id: \.category) { slice in
            SectorMark(
                angle: .value("Total", slice.total),
                innerRadius: .ratio(0.55),
                angularInset: 1.5
            )
            .cornerRadius(4)
            .foregroundStyle(Color(hex: slice.color) ?? .gray)
        }
        .chartLegend(.hidden)
        .frame(height: 220)
    }
}
