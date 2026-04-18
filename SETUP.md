# Setup Guide — ExpenseTracker

This guide assumes you've never built an iOS app before. It'll take about **15 minutes** start-to-finish.

---

## Part 1 — Create the Xcode project (5 min)

1. Open **Xcode**. If you don't have it, install from the Mac App Store — it's free but large (~10 GB).
2. Click **File → New → Project**.
3. Choose **iOS → App**, then **Next**.
4. Fill in:
   - **Product Name**: `ExpenseTracker`
   - **Team**: pick your Apple ID (or "Add an Account…" to sign in with your free Apple ID)
   - **Organization Identifier**: anything unique, e.g. `com.munawar` (reverse-domain style)
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Storage**: `None` (we manage SwiftData ourselves)
   - Leave **Include Tests** unchecked
5. Click **Next**, then save it somewhere (e.g. `~/Documents`).
6. Xcode will generate a default `ExpenseTrackerApp.swift` and `ContentView.swift`. **Delete both** in the Project Navigator (left sidebar) — choose **Move to Trash** when asked. We'll replace them.

---

## Part 2 — Add the source files (3 min)

1. In the Project Navigator (left sidebar in Xcode), right-click the yellow **ExpenseTracker** folder → **New Group** — make these groups:
   - `Models`
   - `ViewModels`
   - `Views`
   - `Views/Components` (inside `Views`)
   - `Utilities`
2. From Finder, open the `ExpenseTracker/` folder in this repo. Drag each `.swift` file into the matching Xcode group. When prompted:
   - ✅ **Copy items if needed**
   - ✅ Create groups (not folder references)
   - ✅ Add to target **ExpenseTracker**

Expected final layout in the Xcode sidebar:

```
ExpenseTracker
├── ExpenseTrackerApp.swift
├── Models/
│   ├── Expense.swift
│   └── ExpenseCategory.swift
├── ViewModels/
│   ├── ExpenseViewModel.swift
│   └── CategoryViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── AddExpenseView.swift
│   ├── HistoryView.swift
│   ├── AnalyticsView.swift
│   ├── CategoriesView.swift
│   └── Components/
│       ├── ExpenseRow.swift
│       ├── CategoryPicker.swift
│       └── SpendPieChart.swift
└── Utilities/
    ├── DefaultCategories.swift
    ├── CurrencyFormatter.swift
    └── CSVExporter.swift
```

---

## Part 3 — Set the deployment target (1 min)

SwiftData and Swift Charts both require iOS 17+.

1. Click the blue **ExpenseTracker** project at the top of the sidebar.
2. Select the **ExpenseTracker** target.
3. Under **General → Minimum Deployments**, set **iOS** to `17.0` or higher.

---

## Part 4 — Build & run on your iPhone (5 min)

### First time only — sign the app

1. Click the project → target **ExpenseTracker** → **Signing & Capabilities** tab.
2. Check **Automatically manage signing**.
3. Under **Team**, pick your Apple ID. (Free ones work — you just get 7-day builds; re-sign weekly.)
4. If it errors, change the **Bundle Identifier** to something globally unique, e.g. `com.munawar.expensetracker`.

### Plug in your iPhone

1. Connect iPhone via USB (or Wi-Fi if already paired).
2. Unlock the phone and tap **Trust This Computer** if prompted.
3. On iPhone: **Settings → Privacy & Security → Developer Mode → On**. The phone will reboot.
4. Back in Xcode, at the top device selector, choose **your iPhone**.
5. Press **⌘R** (or the Play button). First build is slow — ~30s to a minute.
6. On iPhone: **Settings → General → VPN & Device Management → [Your Apple ID] → Trust**. This is only needed once.
7. Re-launch the app from your home screen. Done.

---

## Part 5 — Push to GitHub

I (Claude) can't push to your GitHub without your credentials. Here's the 30-second version — run these in Terminal, in this folder:

```bash
cd /Users/munawar/Documents/Claude_code/FirstApp

# (already done if you cloned) otherwise:
git init
git add .
git commit -m "Initial commit: ExpenseTracker iOS app"

# Create a new empty repo on github.com (no README), then:
git remote add origin https://github.com/<your-username>/ExpenseTracker.git
git branch -M main
git push -u origin main
```

**Even easier — using the GitHub CLI (`brew install gh`):**

```bash
cd /Users/munawar/Documents/Claude_code/FirstApp
gh auth login          # one-time
gh repo create ExpenseTracker --public --source=. --push
```

That creates the repo on GitHub and pushes in one command.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "No such module 'SwiftData'" | Deployment target too old — set to iOS 17.0+. |
| "No such module 'Charts'" | Same — iOS 17.0+. Charts is built-in, no package needed. |
| "Untrusted Developer" on iPhone | Settings → General → VPN & Device Management → trust your profile. |
| App disappears after ~7 days | Free Apple ID limit. Rebuild & re-run from Xcode — it re-signs for another week. |
| Duplicate category crash | SwiftData's `@Attribute(.unique)` rejects same-name categories. Use a different name. |

---

## How the code fits together (for curious readers)

- **`ExpenseTrackerApp`** creates one `ModelContainer` that holds your `Expense` and `ExpenseCategory` records. This is SwiftData's equivalent of a Core Data stack — but about 10× less code.
- **`@Model`** on a class makes it persistent automatically. No `.xcdatamodeld` file needed.
- **`@Query`** in a View fetches + observes records. When you `insert` or `delete`, every View querying that type redraws automatically.
- **ViewModels** are plain `@Observable` classes. They take a `ModelContext` as a parameter rather than owning one — this keeps testing simple and avoids two contexts fighting over the same data.
- **Swift Charts** (`import Charts`) draws the pie chart with 10 lines of code. No third-party libraries.
