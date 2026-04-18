import Foundation

// Turns a list of expenses into a CSV file on disk and returns its URL so we
// can hand it off to a share sheet.
enum CSVExporter {
    static func export(_ expenses: [Expense]) -> URL? {
        let df = ISO8601DateFormatter()
        var rows: [String] = ["Date,Category,Amount,Note"]
        for e in expenses {
            let date = df.string(from: e.date)
            let category = escape(e.category?.name ?? "Uncategorized")
            let amount = String(format: "%.2f", e.amount)
            let note = escape(e.note)
            rows.append("\(date),\(category),\(amount),\(note)")
        }
        let csv = rows.joined(separator: "\n")

        let filename = "expenses-\(Int(Date().timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    // Wrap a field in quotes if it contains a comma, quote, or newline.
    private static func escape(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
}
