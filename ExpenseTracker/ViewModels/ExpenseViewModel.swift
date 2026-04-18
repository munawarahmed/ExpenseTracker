import Foundation
import SwiftData

// ViewModel for adding / editing / deleting expenses and computing monthly stats.
// Views pass their ModelContext in rather than owning one — keeps things simple.
@Observable
final class ExpenseViewModel {
    // MARK: Mutations

    func add(amount: Double, note: String, date: Date,
             category: ExpenseCategory?, context: ModelContext) {
        let expense = Expense(amount: amount, note: note, date: date, category: category)
        context.insert(expense)
        try? context.save()
    }

    func update(_ expense: Expense, amount: Double, note: String,
                date: Date, category: ExpenseCategory?, context: ModelContext) {
        expense.amount = amount
        expense.note = note
        expense.date = date
        expense.category = category
        try? context.save()
    }

    func delete(_ expense: Expense, context: ModelContext) {
        context.delete(expense)
        try? context.save()
    }

    // MARK: Queries for the Analytics tab

    // Total spend for a given calendar month.
    func monthlyTotal(expenses: [Expense], month: Date) -> Double {
        filter(expenses, in: month).reduce(0) { $0 + $1.amount }
    }

    // Returns [(category, total)] sorted biggest-first. Uncategorized lumped as "Uncategorized".
    func breakdown(expenses: [Expense], month: Date)
        -> [(category: String, total: Double, color: String, icon: String)] {
        let filtered = filter(expenses, in: month)
        // Group by category name.
        var buckets: [String: (total: Double, color: String, icon: String)] = [:]
        for e in filtered {
            let key = e.category?.name ?? "Uncategorized"
            let color = e.category?.colorHex ?? "#6C757D"
            let icon = e.category?.iconName ?? "questionmark.circle.fill"
            let prev = buckets[key]?.total ?? 0
            buckets[key] = (prev + e.amount, color, icon)
        }
        return buckets
            .map { (category: $0.key, total: $0.value.total,
                    color: $0.value.color, icon: $0.value.icon) }
            .sorted { $0.total > $1.total }
    }

    // Keep only expenses inside the calendar month of `month`.
    private func filter(_ expenses: [Expense], in month: Date) -> [Expense] {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: month)
        return expenses.filter {
            let c = cal.dateComponents([.year, .month], from: $0.date)
            return c.year == comps.year && c.month == comps.month
        }
    }
}
