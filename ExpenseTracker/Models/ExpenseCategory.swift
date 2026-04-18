import Foundation
import SwiftData
import SwiftUI

// A spending category like "Food" or "Rent". User can add / edit / delete.
@Model
final class ExpenseCategory {
    // Unique name the user types.
    @Attribute(.unique) var name: String
    // SF Symbol name, e.g. "fork.knife".
    var iconName: String
    // Hex string like "#FF8800" — stored as string so SwiftData is happy.
    var colorHex: String
    // Inverse of Expense.category. Deleting a category nullifies expense.category.
    @Relationship(deleteRule: .nullify, inverse: \Expense.category)
    var expenses: [Expense] = []

    init(name: String, iconName: String, colorHex: String) {
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
    }

    // Convenience: turn the stored hex string into a SwiftUI Color.
    var color: Color { Color(hex: colorHex) ?? .gray }
}

// Helper that lets us build SwiftUI Colors from "#RRGGBB" hex strings.
extension Color {
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt64(s, radix: 16) else { return nil }
        let r = Double((v >> 16) & 0xFF) / 255.0
        let g = Double((v >> 8) & 0xFF) / 255.0
        let b = Double(v & 0xFF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
}
