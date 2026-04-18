import SwiftUI
import SwiftData

@main
struct ExpenseTrackerApp: App {
    // SwiftData container holds both Expense and Category models.
    let container: ModelContainer = {
        let schema = Schema([Expense.self, ExpenseCategory.self])
        let config = ModelConfiguration("ExpenseTracker", schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Seed the default categories the first time the app launches.
                    DefaultCategories.seedIfNeeded(context: container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
