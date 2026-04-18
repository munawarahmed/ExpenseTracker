import Foundation
import SwiftData

// Seeds the 13 default categories the first time the app runs.
enum DefaultCategories {
    // Each tuple = (name, SF Symbol, hex color).
    static let items: [(String, String, String)] = [
        ("Food & Dining",        "fork.knife",             "#FF6B6B"),
        ("Groceries / Kitchen",  "cart.fill",              "#4ECDC4"),
        ("Transportation",       "car.fill",               "#45B7D1"),
        ("Bills & Utilities",    "bolt.fill",              "#FFA07A"),
        ("Rent",                 "house.fill",             "#8E7CC3"),
        ("Entertainment",        "gamecontroller.fill",    "#F4A261"),
        ("Shopping",             "bag.fill",               "#E76F51"),
        ("Health & Medical",     "cross.case.fill",        "#2A9D8F"),
        ("Education",            "book.fill",              "#264653"),
        ("Travel",               "airplane",               "#06AED5"),
        ("Donations / Charity",  "heart.fill",             "#E63946"),
        ("Personal Expenses",    "person.fill",            "#9D4EDD"),
        ("Miscellaneous",        "ellipsis.circle.fill",   "#6C757D"),
    ]

    // Only seed if there are zero categories. Prevents duplicates on later launches.
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<ExpenseCategory>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }
        for (name, icon, hex) in items {
            context.insert(ExpenseCategory(name: name, iconName: icon, colorHex: hex))
        }
        try? context.save()
    }
}
