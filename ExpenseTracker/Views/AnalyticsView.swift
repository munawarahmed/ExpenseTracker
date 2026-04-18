import SwiftUI
import SwiftData

// Monthly dashboard: total, pie chart, category breakdown list, budget warning.
struct AnalyticsView: View {
    @Query private var expenses: [Expense]
    @State private var month: Date = .now
    // Persisted monthly budget. 0 = no budget set.
    @AppStorage("monthlyBudget") private var monthlyBudget: Double = 0

    private let vm = ExpenseViewModel()

    private var total: Double { vm.monthlyTotal(expenses: expenses, month: month) }
    private var slices: [(category: String, total: Double, color: String, icon: String)] {
        vm.breakdown(expenses: expenses, month: month)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    monthSwitcher
                    totalCard
                    budgetCard

                    if slices.isEmpty {
                        ContentUnavailableView(
                            "No spending yet",
                            systemImage: "chart.pie",
                            description: Text("Add an expense to see your breakdown.")
                        )
                        .padding(.top, 40)
                    } else {
                        SpendPieChart(slices: slices)
                            .padding(.horizontal)
                        breakdownList
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
        }
    }

    // MARK: - Sub-views

    // Prev / next month nav. Disables forward past current month.
    private var monthSwitcher: some View {
        HStack {
            Button { shiftMonth(-1) } label: { Image(systemName: "chevron.left") }
            Spacer()
            Text(month, format: .dateTime.month(.wide).year())
                .font(.title3.weight(.semibold))
            Spacer()
            Button { shiftMonth(1) } label: { Image(systemName: "chevron.right") }
                .disabled(isCurrentMonth)
        }
        .padding(.horizontal)
    }

    private var totalCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Total spent").font(.caption).foregroundStyle(.secondary)
            Text(CurrencyFormatter.string(from: total))
                .font(.system(size: 38, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .padding(.horizontal)
    }

    // Shows the monthly budget + progress. Tap the bar to set a new one.
    private var budgetCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Monthly budget").font(.caption).foregroundStyle(.secondary)
                Spacer()
                if monthlyBudget > 0 {
                    Text("\(CurrencyFormatter.string(from: total)) / \(CurrencyFormatter.string(from: monthlyBudget))")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }

            if monthlyBudget > 0 {
                let ratio = min(total / monthlyBudget, 1.0)
                ProgressView(value: ratio)
                    .tint(ratio >= 1 ? .red : (ratio >= 0.8 ? .orange : .green))
                if ratio >= 1 {
                    Label("Over budget!", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption).foregroundStyle(.red)
                } else if ratio >= 0.8 {
                    Label("Close to your limit", systemImage: "exclamationmark.circle")
                        .font(.caption).foregroundStyle(.orange)
                }
            } else {
                Text("No budget set").font(.caption).foregroundStyle(.secondary)
            }

            // Inline editor so there's no extra screen to navigate to.
            HStack {
                Text("Set budget")
                Spacer()
                TextField("0", value: $monthlyBudget,
                          format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
            }
            .font(.subheadline)
            .padding(.top, 4)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .padding(.horizontal)
    }

    private var breakdownList: some View {
        VStack(spacing: 0) {
            ForEach(slices, id: \.category) { s in
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill((Color(hex: s.color) ?? .gray).opacity(0.18))
                            .frame(width: 36, height: 36)
                        Image(systemName: s.icon)
                            .foregroundStyle(Color(hex: s.color) ?? .gray)
                    }
                    VStack(alignment: .leading) {
                        Text(s.category).font(.subheadline.weight(.medium))
                        Text(percent(s.total)).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(CurrencyFormatter.string(from: s.total))
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                Divider().padding(.leading, 60)
            }
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func percent(_ amount: Double) -> String {
        guard total > 0 else { return "0%" }
        return String(format: "%.0f%%", (amount / total) * 100)
    }

    private func shiftMonth(_ delta: Int) {
        if let new = Calendar.current.date(byAdding: .month, value: delta, to: month) {
            month = new
        }
    }

    private var isCurrentMonth: Bool {
        let cal = Calendar.current
        let a = cal.dateComponents([.year, .month], from: month)
        let b = cal.dateComponents([.year, .month], from: .now)
        return a.year == b.year && a.month == b.month
    }
}
