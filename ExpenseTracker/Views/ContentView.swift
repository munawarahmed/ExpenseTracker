import SwiftUI

// Root view with four tabs. Each tab is its own independent navigation stack.
struct ContentView: View {
    var body: some View {
        TabView {
            AddExpenseView()
                .tabItem { Label("Add", systemImage: "plus.circle.fill") }

            HistoryView()
                .tabItem { Label("History", systemImage: "list.bullet.rectangle") }

            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.pie.fill") }

            CategoriesView()
                .tabItem { Label("Categories", systemImage: "tag.fill") }
        }
    }
}
