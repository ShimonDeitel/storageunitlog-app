import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var editingEntry: BoxEntry?
    @State private var showingSettings = false
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            List {
                if store.entries.isEmpty {
                    ContentUnavailableView("No Entries Yet", systemImage: "tray", description: Text("Tap + to add your first entry."))
                }
                ForEach(store.entries) { entry in
                    Button {
                        editingEntry = entry
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.contents)
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.textPrimary)
                            Text(entry.date, style: .date)
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                }
                .onDelete { offsets in
                    store.delete(at: offsets)
                }
            }
            .navigationTitle("Storage Unit Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(mode: .add)
                    .environmentObject(store)
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(mode: .edit(entry))
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(store)
                    .environmentObject(purchases)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(purchases)
            }
            .onChange(of: store.presentPaywall) { _, newValue in
                if newValue {
                    showingPaywall = true
                    store.presentPaywall = false
                }
            }
        }
    }
}

enum EntryFormMode: Identifiable {
    case add
    case edit(BoxEntry)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let e): return e.id.uuidString
        }
    }
}

struct EntryFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    let mode: EntryFormMode

    @State private var date: Date = Date()
    @State private var contents: String = ""
    @State private var notes: String = ""
    @FocusState private var focusedField: Field?

    enum Field { case f2, notes }

    init(mode: EntryFormMode) {
        self.mode = mode
        if case .edit(let entry) = mode {
            _date = State(initialValue: entry.date)
            _contents = State(initialValue: entry.contents)
            _notes = State(initialValue: entry.notes)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date Stored", selection: $date, displayedComponents: .date)
                    .accessibilityIdentifier("entryDateField")
                TextField("Contents", text: $contents)
                    .accessibilityIdentifier("entryPrimaryField")
                    .focused($focusedField, equals: .f2)
                TextField("Notes", text: $notes, axis: .vertical)
                    .accessibilityIdentifier("entryNotesField")
                    .focused($focusedField, equals: .notes)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("entryCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("entrySaveButton")
                    .disabled(contents.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func save() {
        switch mode {
        case .add:
            let entry = BoxEntry(date: date, contents: contents, notes: notes)
            store.add(entry)
        case .edit(let existing):
            var updated = existing
            updated.date = date
            updated.contents = contents
            updated.notes = notes
            store.update(updated)
        }
    }
}
