import Foundation
import SwiftData

// Handles creating / renaming / deleting categories. Deleting a category
// nullifies the relationship on its expenses (set up in the model) rather than
// cascade-deleting them, so the user doesn't lose history.
@Observable
final class CategoryViewModel {
    func add(name: String, icon: String, hex: String, context: ModelContext) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        context.insert(ExpenseCategory(name: trimmed, iconName: icon, colorHex: hex))
        try? context.save()
    }

    func update(_ category: ExpenseCategory, name: String, icon: String,
                hex: String, context: ModelContext) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        category.name = trimmed
        category.iconName = icon
        category.colorHex = hex
        try? context.save()
    }

    func delete(_ category: ExpenseCategory, context: ModelContext) {
        context.delete(category)
        try? context.save()
    }

    // Move every expense from `from` to `to` (used when user wants to merge).
    func reassignExpenses(from: ExpenseCategory, to: ExpenseCategory,
                          context: ModelContext) {
        for expense in from.expenses {
            expense.category = to
        }
        try? context.save()
    }
}
