import SwiftUI

struct PresetPickerView: View {
    @Binding var selectedKey: String
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Preset) -> Void
    let onProRequired: () -> Void  // Phase 1: Callback for Pro-only presets
    
    @StateObject private var proManager = ProManager.shared
    @State private var selectedCategory: PresetCategory = .pop
    
    private let keys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    // Filter presets based on Pro status
    private var availablePresets: [Preset] {
        let categoryPresets = Preset.byCategory(selectedCategory)
        if proManager.isProUser {
            return categoryPresets
        } else {
            return categoryPresets.filter { $0.isFree }
        }
    }
    
    private var proOnlyPresets: [Preset] {
        Preset.byCategory(selectedCategory).filter { !$0.isFree }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Key Selection
                VStack(spacing: 12) {
                    Text("Select Key")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(keys, id: \.self) { key in
                                Button(action: {
                                    selectedKey = key
                                }) {
                                    Text(key)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .frame(minWidth: 50)
                                        .padding(.vertical, 12)
                                        .background(selectedKey == key ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedKey == key ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Category Picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(PresetCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Preset List
                List {
                    // Available Presets (Free or Pro)
                    SwiftUI.Section {
                        ForEach(availablePresets) { preset in
                            Button(action: {
                                onSelect(preset)
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(preset.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(preset.romanNumerals.joined(separator: " → "))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text(preset.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if !preset.isFree && proManager.isProUser {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // Pro-only Presets (locked for Free users)
                    if !proManager.isProUser && !proOnlyPresets.isEmpty {
                        SwiftUI.Section(header: Text("Pro Only")) {
                            ForEach(proOnlyPresets) { preset in
                                Button(action: {
                                    onProRequired()
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(preset.name)
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                            
                                            Text(preset.romanNumerals.joined(separator: " → "))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Text(preset.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PresetPickerView(
        selectedKey: .constant("C"),
        onSelect: { preset in
            print("Selected: \(preset.name)")
        },
        onProRequired: {
            print("Pro required")
        }
    )
}


