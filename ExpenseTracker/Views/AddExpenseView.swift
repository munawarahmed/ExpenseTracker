import SwiftUI
import SwiftData

// The "fast entry" screen. Goal: tap amount → tap category → save. < 5 seconds.
struct AddExpenseView: View {
    @Environment(\.modelContext) private var context
    // Query categories sorted by name for the picker strip.
    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]

    @State private var amount: Double? = nil
    @State private var note: String = ""
    @State private var date: Date = .now
    @State private var selectedCategory: ExpenseCategory? = nil
    @State private var showSavedBanner = false

    @FocusState private var amountFocused: Bool
    private let vm = ExpenseViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("0.00", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                        .font(.largeTitle.weight(.semibold))
                        .focused($amountFocused)
                }

                Section("Category") {
                    CategoryPicker(categories: categories, selected: $selectedCategory)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 8)
                }

                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Note (optional)") {
                    TextField("e.g. lunch with Alex", text: $note, axis: .vertical)
                        .lineLimit(1...3)
                }

                Section {
                    Button {
                        save()
                    } label: {
                        Text("Save Expense")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSave)
                }
            }
            .navigationTitle("Add Expense")
            .onAppear {
                // Pre-select the first category so one fewer tap is needed.
                if selectedCategory == nil { selectedCategory = categories.first }
                // Auto-focus amount to skip a tap.
                amountFocused = true
            }
            .overlay(alignment: .top) {
                if showSavedBanner {
                    Text("Saved ✓")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().fill(.green.opacity(0.9)))
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    private var canSave: Bool {
        (amount ?? 0) > 0 && selectedCategory != nil
    }

    private func save() {
        guard let amount, canSave else { return }
        vm.add(amount: amount, note: note, date: date,
               category: selectedCategory, context: context)
        // Reset for the next entry, but keep the category selected — people
        // often log several in the same category in a row.
        self.amount = nil
        self.note = ""
        self.date = .now

        withAnimation { showSavedBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showSavedBanner = false }
        }
        amountFocused = true
    }
}
