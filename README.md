# ExpenseTracker

A clean, fast, native iPhone app for personal expense tracking.

Built with **SwiftUI**, **SwiftData**, and **Swift Charts** — Apple's newest, most modern stack.

## Features

- **Fast entry**: amount + category + save in under 5 seconds.
- **13 built-in categories** (Food, Rent, Transport, etc.) — all editable, addable, deletable.
- **Monthly analytics** with pie chart, category breakdown, percentages.
- **Budget warning** when you hit 80% / 100% of a monthly cap.
- **History** with category + date filters, swipe-to-delete, tap-to-edit.
- **CSV export** via the iOS share sheet.
- **Dark mode** — automatic, follows system setting.
- **100% offline** — data stored locally on-device via SwiftData (no cloud, no account).

## Architecture (MVVM)

```
ExpenseTracker/
├── ExpenseTrackerApp.swift      # App entry + SwiftData container
├── Models/
│   ├── Expense.swift            # @Model — one spend event
│   └── ExpenseCategory.swift    # @Model — a category, w/ Color(hex:) helper
├── ViewModels/
│   ├── ExpenseViewModel.swift   # Add/edit/delete + monthly math
│   └── CategoryViewModel.swift  # Add/edit/delete/reassign categories
├── Views/
│   ├── ContentView.swift        # Root TabView
│   ├── AddExpenseView.swift     # "Fast entry" tab
│   ├── HistoryView.swift        # Filterable list + edit sheet + export
│   ├── AnalyticsView.swift      # Monthly dashboard
│   ├── CategoriesView.swift     # Manage categories
│   └── Components/
│       ├── ExpenseRow.swift
│       ├── CategoryPicker.swift
│       └── SpendPieChart.swift
└── Utilities/
    ├── DefaultCategories.swift  # Seeds the 13 defaults on first launch
    ├── CurrencyFormatter.swift
    └── CSVExporter.swift
```

## Requirements

- macOS with **Xcode 15 or newer**
- iPhone running **iOS 17 or newer**
- Free Apple ID (for on-device installation — no paid developer account needed)

## Setup

See [SETUP.md](SETUP.md) for a step-by-step walkthrough of:

1. Creating the Xcode project
2. Adding these source files
3. Running on your iPhone
4. Pushing this to GitHub

## License

MIT — use it however you want.
