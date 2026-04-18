import SwiftUI
import SwiftData

// Manage categories: add, rename, change icon / color, delete.
struct CategoriesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ExpenseCategory.name) private var categories: [ExpenseCategory]

    @State private var editing: ExpenseCategory? = nil
    @State private var showingAdd = false

    private let vm = CategoryViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { c in
                    Button { editing = c } label: {
                        HStack {
                            ZStack {
                                Circle().fill(c.color.opacity(0.18))
                                    .frame(width: 36, height: 36)
                                Image(systemName: c.iconName).foregroundStyle(c.color)
                            }
                            VStack(alignment: .leading) {
                                Text(c.name).foregroundStyle(.primary)
                                Text("\(c.expenses.count) expenses")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption).foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                CategoryEditor(mode: .add)
            }
            .sheet(item: $editing) { cat in
                CategoryEditor(mode: .edit(cat))
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets { vm.delete(categories[i], context: context) }
    }
}

// Reusable editor for add + edit. `mode` controls which one we're doing.
private struct CategoryEditor: View {
    enum Mode { case add, edit(ExpenseCategory) }
    let mode: Mode

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var icon = "tag.fill"
    @State private var hex = "#4ECDC4"

    // Curated list — more than enough for a personal finance app.
    private let icons = ["tag.fill","fork.knife","cart.fill","car.fill","bolt.fill",
                         "house.fill","gamecontroller.fill","bag.fill","cross.case.fill",
                         "book.fill","airplane","heart.fill","person.fill",
                         "creditcard.fill","gift.fill","pawprint.fill","dumbbell.fill",
                         "cup.and.saucer.fill","tram.fill","fuelpump.fill"]
    private let palette = ["#FF6B6B","#4ECDC4","#45B7D1","#FFA07A","#8E7CC3",
                           "#F4A261","#E76F51","#2A9D8F","#264653","#06AED5",
                           "#E63946","#9D4EDD","#6C757D","#20C997","#FD7E14"]

    private let vm = CategoryViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") { TextField("e.g. Coffee", text: $name) }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                        ForEach(icons, id: \.self) { i in
                            Button { icon = i } label: {
                                Image(systemName: i)
                                    .font(.title2)
                                    .frame(width: 40, height: 40)
                                    .background(Circle().fill(i == icon ? Color.accentColor.opacity(0.2) : Color.clear))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                        ForEach(palette, id: \.self) { h in
                            Button { hex = h } label: {
                                Circle()
                                    .fill(Color(hex: h) ?? .gray)
                                    .frame(width: 34, height: 34)
                                    .overlay(
                                        Circle().stroke(
                                            h == hex ? Color.primary : .clear,
                                            lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Preview").foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: icon).foregroundStyle(Color(hex: hex) ?? .gray)
                        Text(name.isEmpty ? "Category name" : name)
                    }
                }
            }
            .navigationTitle(isEdit ? "Edit Category" : "New Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if case .edit(let cat) = mode {
                    name = cat.name
                    icon = cat.iconName
                    hex = cat.colorHex
                }
            }
        }
    }

    private var isEdit: Bool { if case .edit = mode { return true }; return false }

    private func save() {
        switch mode {
        case .add:
            vm.add(name: name, icon: icon, hex: hex, context: context)
        case .edit(let cat):
            vm.update(cat, name: name, icon: icon, hex: hex, context: context)
        }
        dismiss()
    }
}
