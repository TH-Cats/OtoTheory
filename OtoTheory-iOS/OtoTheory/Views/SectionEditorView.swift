//
//  SectionEditorView.swift
//  OtoTheory
//
//  Phase 2: Section editing UI
//

import SwiftUI

struct SectionEditorView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var sections: [Section]
    let maxBars: Int
    
    @State private var showAddSheet = false
    @State private var editingSection: Section?
    
    var body: some View {
        NavigationView {
            List {
                if sections.isEmpty {
                    ContentUnavailableView(
                        "No Sections",
                        systemImage: "music.note.list",
                        description: Text("Add sections to structure your song")
                    )
                } else {
                    ForEach(sections.sortedByRange) { section in
                        SectionRow(section: section) {
                            editingSection = section
                        }
                    }
                    .onDelete(perform: deleteSections)
                    .onMove(perform: moveSections)
                }
            }
            .navigationTitle("Sections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showAddSheet) {
                SectionDetailView(
                    section: nil,
                    maxBars: maxBars,
                    existingSections: sections,
                    onSave: { newSection in
                        sections.append(newSection)
                        showAddSheet = false
                    }
                )
            }
            .sheet(item: $editingSection) { section in
                SectionDetailView(
                    section: section,
                    maxBars: maxBars,
                    existingSections: sections.filter { $0.id != section.id },
                    onSave: { updatedSection in
                        if let index = sections.firstIndex(where: { $0.id == section.id }) {
                            sections[index] = updatedSection
                        }
                        editingSection = nil
                    }
                )
            }
        }
    }
    
    private func deleteSections(at offsets: IndexSet) {
        let sorted = sections.sortedByRange
        let idsToRemove = offsets.map { sorted[$0].id }
        sections.removeAll { idsToRemove.contains($0.id) }
    }
    
    private func moveSections(from source: IndexSet, to destination: Int) {
        var sorted = sections.sortedByRange
        sorted.move(fromOffsets: source, toOffset: destination)
        sections = sorted
    }
}

// MARK: - Section Row

struct SectionRow: View {
    let section: Section
    let onEdit: () -> Void
    
    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 12) {
                Image(systemName: section.name.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.name.displayName)
                        .font(.headline)
                    
                    Text("Bars \(section.range.lowerBound + 1)-\(section.range.upperBound + 1)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if section.repeatCount > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .font(.caption)
                        Text("×\(section.repeatCount)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Section Detail View

struct SectionDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let section: Section?  // nil = create new
    let maxBars: Int
    let existingSections: [Section]
    let onSave: (Section) -> Void
    
    @State private var selectedType: SectionType
    @State private var startBar: Int
    @State private var endBar: Int
    @State private var repeatCount: Int
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(section: Section?, maxBars: Int, existingSections: [Section], onSave: @escaping (Section) -> Void) {
        self.section = section
        self.maxBars = maxBars
        self.existingSections = existingSections
        self.onSave = onSave
        
        // Initialize state
        _selectedType = State(initialValue: section?.name ?? .verse)
        _startBar = State(initialValue: section?.range.lowerBound ?? 0)
        _endBar = State(initialValue: section?.range.upperBound ?? min(3, maxBars - 1))
        _repeatCount = State(initialValue: section?.repeatCount ?? 1)
    }
    
    var isEditing: Bool {
        section != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                SwiftUI.Section("Section Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(SectionType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                SwiftUI.Section("Range") {
                    Stepper("Start Bar: \(startBar + 1)", value: $startBar, in: 0...(maxBars - 1))
                    Stepper("End Bar: \(endBar + 1)", value: $endBar, in: startBar...(maxBars - 1))
                    
                    Text("\(barCount) bar\(barCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                SwiftUI.Section("Repeat") {
                    Stepper("Repeat: ×\(repeatCount)", value: $repeatCount, in: 1...8)
                    
                    if repeatCount > 1 {
                        Text("This section will play \(repeatCount) times")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                SwiftUI.Section {
                    Button(action: saveSection) {
                        Text(isEditing ? "Update Section" : "Add Section")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Section" : "New Section")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var barCount: Int {
        endBar - startBar + 1
    }
    
    private func saveSection() {
        // Validate range
        guard startBar <= endBar else {
            errorMessage = "Start bar must be before or equal to end bar"
            showError = true
            return
        }
        
        let range = startBar...endBar
        
        // Check for overlaps with existing sections
        for existing in existingSections {
            if range.overlaps(existing.range) {
                errorMessage = "This range overlaps with '\(existing.name.displayName)'"
                showError = true
                return
            }
        }
        
        // Create or update section
        let newSection = Section(
            id: section?.id ?? UUID(),
            name: selectedType,
            range: range,
            repeatCount: repeatCount
        )
        
        onSave(newSection)
    }
}

// MARK: - Preview

#Preview {
    SectionEditorView(
        sections: .constant([
            Section(name: .verse, range: 0...3),
            Section(name: .chorus, range: 4...7, repeatCount: 2),
            Section(name: .bridge, range: 8...11)
        ]),
        maxBars: 12
    )
}

