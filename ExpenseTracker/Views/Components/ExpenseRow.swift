import SwiftUI

// One row in the history / search list. Keeps the whole app visually consistent.
struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack(spacing: 12) {
            // Colored circle with the category icon.
            ZStack {
                Circle()
                    .fill((expense.category?.color ?? .gray).opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: expense.category?.iconName ?? "questionmark.circle.fill")
                    .foregroundStyle(expense.category?.color ?? .gray)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category?.name ?? "Uncategorized")
                    .font(.body.weight(.medium))
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text(expense.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(CurrencyFormatter.string(from: expense.amount))
                .font(.body.weight(.semibold))
        }
        .padding(.vertical, 4)
    }
}
