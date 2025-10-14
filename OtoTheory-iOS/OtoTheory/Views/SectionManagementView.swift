//
//  SectionManagementView.swift
//  OtoTheory
//
//  Phase E-5: Section definition management UI
//

import SwiftUI

struct SectionManagementView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: ProgressionStore
    @StateObject private var proManager = ProManager.shared
    
    @State private var showAddSection = false
    @State private var editingSection: SectionDefinition?
    @State private var showPlaybackOrder = false
    
    var body: some View {
        NavigationView {
            List {
                // Section Definitions
                SwiftUI.Section {
                    if store.sectionDefinitions.isEmpty {
                        ContentUnavailableView(
                            "No Sections",
                            systemImage: "music.note.list",
                            description: Text("Create sections to organize your progression")
                        )
                    } else {
                        ForEach(store.sectionDefinitions) { section in
                            SectionDefinitionRow(
                                section: section,
                                isCurrent: store.currentSectionId == section.id,
                                onSelect: {
                                    store.currentSectionId = section.id
                                },
                                onEdit: {
                                    editingSection = section
                                },
                                onDuplicate: {
                                    duplicateSection(section)
                                },
                                onDelete: {
                                    store.deleteSection(id: section.id)
                                }
                            )
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                store.deleteSection(id: store.sectionDefinitions[index].id)
                            }
                        }
                    }
                } header: {
                    Text("Section Definitions")
                } footer: {
                    if !store.sectionDefinitions.isEmpty {
                        Text("\(store.sectionDefinitions.count) section\(store.sectionDefinitions.count == 1 ? "" : "s") defined")
                            .font(.caption)
                    }
                }
                
                // Playback Order
                SwiftUI.Section {
                    Button(action: { showPlaybackOrder = true }) {
                        HStack {
                            Image(systemName: "list.number")
                            Text("Edit Playback Order")
                            Spacer()
                            if !store.playbackOrder.items.isEmpty {
                                Text("\(store.playbackOrder.items.count) item\(store.playbackOrder.items.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Song Structure")
                }
            }
            .navigationTitle("Manage Sections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSection = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddSection) {
                SectionEditorSheet(
                    section: nil,
                    onSave: { name, type in
                        _ = store.createSection(name: name, type: type)
                        showAddSection = false
                    }
                )
            }
            .sheet(item: $editingSection) { section in
                SectionEditorSheet(
                    section: section,
                    onSave: { name, type in
                        if let index = store.sectionDefinitions.firstIndex(where: { $0.id == section.id }) {
                            store.sectionDefinitions[index].name = name
                            store.sectionDefinitions[index].type = type
                        }
                        editingSection = nil
                    }
                )
            }
            .sheet(isPresented: $showPlaybackOrder) {
                PlaybackOrderEditor(store: store)
            }
        }
    }
    
    private func duplicateSection(_ section: SectionDefinition) {
        let newName = "\(section.name) Copy"
        _ = store.duplicateSection(id: section.id, withName: newName)
    }
}

// MARK: - Section Definition Row

struct SectionDefinitionRow: View {
    let section: SectionDefinition
    let isCurrent: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: section.type.icon)
                    .font(.title3)
                    .foregroundColor(isCurrent ? .white : .blue)
                    .frame(width: 32)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(section.name)
                            .font(.headline)
                            .foregroundColor(isCurrent ? .white : .primary)
                        
                        if isCurrent {
                            Text("EDITING")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack {
                        Text(section.type.displayName)
                            .font(.caption)
                            .foregroundColor(isCurrent ? .white.opacity(0.8) : .secondary)
                        
                        Text("•")
                            .foregroundColor(isCurrent ? .white.opacity(0.8) : .secondary)
                        
                        Text("\(section.filledSlotsCount)/12 chords")
                            .font(.caption)
                            .foregroundColor(isCurrent ? .white.opacity(0.8) : .secondary)
                    }
                }
                
                Spacer()
                
                // Actions Menu
                Menu {
                    Button(action: onEdit) {
                        Label("Edit Name", systemImage: "pencil")
                    }
                    
                    Button(action: onDuplicate) {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(isCurrent ? .white : .secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(isCurrent ? Color.blue : nil)
    }
}

// MARK: - Section Editor Sheet

struct SectionEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let section: SectionDefinition?
    let onSave: (String, SectionType) -> Void
    
    @State private var name: String
    @State private var type: SectionType
    
    init(section: SectionDefinition?, onSave: @escaping (String, SectionType) -> Void) {
        self.section = section
        self.onSave = onSave
        let defaultType = section?.type ?? .verse
        _name = State(initialValue: section?.name ?? defaultType.displayName)
        _type = State(initialValue: defaultType)
    }
    
    var body: some View {
        NavigationView {
            Form {
                SwiftUI.Section("Section Name") {
                    TextField("e.g., Verse 1, Chorus A", text: $name)
                }
                
                SwiftUI.Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(SectionType.allCases, id: \.self) { sectionType in
                            HStack {
                                Image(systemName: sectionType.icon)
                                Text(sectionType.displayName)
                            }
                            .tag(sectionType)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: type) { oldValue, newValue in
                        // Auto-update name if it matches the old type name
                        if section == nil && name == oldValue.displayName {
                            name = newValue.displayName
                        }
                    }
                }
            }
            .navigationTitle(section == nil ? "New Section" : "Edit Section")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !name.isEmpty {
                            onSave(name, type)
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Playback Order Editor

struct PlaybackOrderEditor: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: ProgressionStore
    
    @State private var showAddSection = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Preview Header
                if !store.playbackOrder.items.isEmpty {
                    previewHeader
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemGroupedBackground))
                }
                
                // Playback Order List
                if store.playbackOrder.items.isEmpty {
                    emptyState
                } else {
                    playbackOrderList
                }
            }
            .navigationTitle("Playback Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showAddSection = true }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(store.sectionDefinitions.isEmpty)
                        
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showAddSection) {
                AddToPlaybackOrderSheet(store: store)
            }
        }
    }
    
    // MARK: - Preview Header
    
    @ViewBuilder
    private var previewHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "music.note.list")
                    .foregroundColor(.secondary)
                Text("Song Structure Preview")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Sections")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(store.playbackOrder.items.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Chords")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(totalChordCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    private var totalChordCount: Int {
        store.combinedProgression.compactMap { $0 }.count
    }
    
    // MARK: - Empty State
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "list.number")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Playback Order")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add sections to define the song structure")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if !store.sectionDefinitions.isEmpty {
                Button(action: { showAddSection = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add First Section")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Playback Order List
    
    @ViewBuilder
    private var playbackOrderList: some View {
        List {
            ForEach(store.playbackOrder.items) { item in
                if let section = store.sectionDefinitions.first(where: { $0.id == item.sectionId }) {
                    PlaybackItemRow(
                        section: section,
                        repeatCount: item.repeatCount,
                        onRepeatChange: { newCount in
                            if let index = store.playbackOrder.items.firstIndex(where: { $0.id == item.id }) {
                                store.playbackOrder.items[index].repeatCount = newCount
                            }
                        }
                    )
                } else {
                    // Orphaned item (section was deleted)
                    Text("Unknown Section")
                        .foregroundColor(.red)
                }
            }
            .onDelete { offsets in
                store.playbackOrder.items.remove(atOffsets: offsets)
            }
            .onMove { source, destination in
                store.playbackOrder.items.move(fromOffsets: source, toOffset: destination)
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct PlaybackItemRow: View {
    let section: SectionDefinition
    let repeatCount: Int
    let onRepeatChange: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: section.type.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(section.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text(section.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(section.filledSlotsCount) chords")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Repeat Counter with +/- buttons
            HStack(spacing: 8) {
                Button(action: {
                    if repeatCount > 1 {
                        onRepeatChange(repeatCount - 1)
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(repeatCount > 1 ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(repeatCount <= 1)
                
                Text("×\(repeatCount)")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(minWidth: 30)
                
                Button(action: {
                    if repeatCount < 99 {
                        onRepeatChange(repeatCount + 1)
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(repeatCount < 99 ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(repeatCount >= 99)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add to Playback Order Sheet

struct AddToPlaybackOrderSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: ProgressionStore
    
    @State private var selectedSectionId: UUID?
    @State private var repeatCount: Int = 1
    
    var body: some View {
        NavigationView {
            Form {
                // Section Selection
                SwiftUI.Section("Select Section") {
                    if store.sectionDefinitions.isEmpty {
                        Text("No sections available")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(store.sectionDefinitions) { section in
                            Button(action: {
                                selectedSectionId = section.id
                            }) {
                                HStack {
                                    Image(systemName: section.type.icon)
                                        .foregroundColor(.accentColor)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(section.name)
                                            .foregroundColor(.primary)
                                        Text("\(section.filledSlotsCount) chords")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedSectionId == section.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Repeat Count
                if selectedSectionId != nil {
                    SwiftUI.Section("Repeat Count") {
                        Stepper(value: $repeatCount, in: 1...99) {
                            HStack {
                                Text("Play")
                                Text("×\(repeatCount)")
                                    .fontWeight(.semibold)
                                Text("times")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add to Playback Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addToPlaybackOrder()
                        dismiss()
                    }
                    .disabled(selectedSectionId == nil)
                }
            }
        }
    }
    
    private func addToPlaybackOrder() {
        guard let sectionId = selectedSectionId else { return }
        
        let item = PlaybackItem(sectionId: sectionId, repeatCount: repeatCount)
        store.playbackOrder.items.append(item)
    }
}

#Preview {
    let store = ProgressionStore.shared
    store.useSectionMode = true
    _ = store.createSection(name: "Verse 1", type: .verse)
    _ = store.createSection(name: "Chorus", type: .chorus)
    return SectionManagementView(store: store)
}

