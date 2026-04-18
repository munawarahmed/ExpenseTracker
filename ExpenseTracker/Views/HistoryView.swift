import SwiftUI
import SwiftData

// All expenses, filterable by category and date range. Swipe to delete or tap to edit.
struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]

    @State private var filterCategory: ExpenseCategory? = nil
    @State private var filterStart: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var filterEnd: Date = .now
    @State private var useDateFilter = false
    @State private var editing: Expense? = nil
    @State private var showExportSheet = false
    @State private var exportURL: URL? = nil

    private let vm = ExpenseViewModel()

    // Apply filters in-memory — dataset is small enough this is fine.
    var filtered: [Expense] {
        expenses.filter { e in
            if let cat = filterCategory, e.category?.id != cat.id { return false }
            if useDateFilter {
                if e.date < Calendar.current.startOfDay(for: filterStart) { return false }
                let endOfDay = Calendar.current.date(
                    bySettingHour: 23, minute: 59, second: 59, of: filterEnd) ?? filterEnd
                if e.date > endOfDay { return false }
            }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Category", selection: $filterCategory) {
                        Text("All").tag(ExpenseCategory?.none)
                        ForEach(categories) { c in
                            Text(c.name).tag(ExpenseCategory?.some(c))
                        }
                    }
                    Toggle("Filter by date", isOn: $useDateFilter)
                    if useDateFilter {
                        DatePicker("From", selection: $filterStart, displayedComponents: .date)
                        DatePicker("To", selection: $filterEnd, displayedComponents: .date)
                    }
                } header: { Text("Filters") }

                Section {
                    if filtered.isEmpty {
                        ContentUnavailableView(
                            "No expenses",
                            systemImage: "tray",
                            description: Text("Try adjusting your filters or add an expense.")
                        )
                    } else {
                        ForEach(filtered) { expense in
                            Button { editing = expense } label: {
                                ExpenseRow(expense: expense)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: delete)
                    }
                } header: {
                    HStack {
                        Text("Entries (\(filtered.count))")
                        Spacer()
                        Text(CurrencyFormatter.string(from: filtered.reduce(0) { $0 + $1.amount }))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let url = CSVExporter.export(filtered) {
                            exportURL = url
                            showExportSheet = true
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(filtered.isEmpty)
                }
            }
            .sheet(item: $editing) { expense in
                EditExpenseView(expense: expense)
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            vm.delete(filtered[i], context: context)
        }
    }
}

// Simple edit sheet. Same VM as Add.
private struct EditExpenseView: View {
    @Bindable var expense: Expense
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Amount", value: $expense.amount,
                          format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)

                CategoryPicker(
                    categories: categories,
                    selected: Binding(
                        get: { expense.category },
                        set: { expense.category = $0 }
                    )
                )
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 8)

                DatePicker("Date", selection: $expense.date, displayedComponents: .date)
                TextField("Note", text: $expense.note, axis: .vertical)
            }
            .navigationTitle("Edit Expense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? context.save()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// Wrap UIKit's activity controller so SwiftUI can present it for CSV export.
private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
