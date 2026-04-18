import Foundation
import SwiftData

// An Expense is a single money-out event. SwiftData auto-persists this to disk.
@Model
final class Expense {
    var amount: Double
    var note: String
    var date: Date
    // Each expense belongs to one category. The inverse is defined on ExpenseCategory.
    var category: ExpenseCategory?

    init(amount: Double, note: String = "", date: Date = .now, category: ExpenseCategory? = nil) {
        self.amount = amount
        self.note = note
        self.date = date
        self.category = category
    }
}
