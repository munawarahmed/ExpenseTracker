import Foundation

// Single source of truth for money formatting. Uses the device locale so it
// looks right regardless of where the user is.
enum CurrencyFormatter {
    static let shared: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = .current
        return f
    }()

    static func string(from value: Double) -> String {
        shared.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}
