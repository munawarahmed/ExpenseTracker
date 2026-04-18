import SwiftUI
import SwiftData

// Horizontal scroll of category chips. Tap one to select — big tap targets make
// entry fast, which is the whole point of this app.
struct CategoryPicker: View {
    let categories: [ExpenseCategory]
    @Binding var selected: ExpenseCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories) { cat in
                    Button {
                        selected = cat
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.iconName)
                            Text(cat.name)
                                .lineLimit(1)
                        }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(
                                selected?.id == cat.id
                                    ? cat.color.opacity(0.25)
                                    : Color(.secondarySystemBackground)
                            )
                        )
                        .overlay(
                            Capsule().stroke(
                                selected?.id == cat.id ? cat.color : .clear,
                                lineWidth: 2
                            )
                        )
                        .foregroundStyle(selected?.id == cat.id ? cat.color : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
