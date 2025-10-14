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
                
                // Category Selector (Chip Style)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Genre")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(PresetCategory.allCases, id: \.self) { category in
                                let count = Preset.byCategory(category).count
                                let freeCount = Preset.byCategory(category).filter { $0.isFree }.count
                                let proCount = count - freeCount
                                
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    VStack(spacing: 4) {
                                        Text(category.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        if proManager.isProUser {
                                            Text("\(count)")
                                                .font(.caption2)
                                                .foregroundColor(selectedCategory == category ? .white : .secondary)
                                        } else {
                                            HStack(spacing: 2) {
                                                Text("\(freeCount)")
                                                    .font(.caption2)
                                                if proCount > 0 {
                                                    Text("+\(proCount)")
                                                        .font(.caption2)
                                                    Image(systemName: "lock.fill")
                                                        .font(.system(size: 8))
                                                }
                                            }
                                            .foregroundColor(selectedCategory == category ? .white : .secondary)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedCategory == category
                                            ? Color.blue
                                            : Color.gray.opacity(0.15)
                                    )
                                    .foregroundColor(
                                        selectedCategory == category
                                            ? .white
                                            : .primary
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                
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
                        SwiftUI.Section {
                            ForEach(proOnlyPresets) { preset in
                                Button(action: {
                                    onProRequired()
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(preset.name)
                                                    .font(.headline)
                                                    .foregroundColor(.secondary)
                                                
                                                Image(systemName: "star.fill")
                                                    .font(.caption2)
                                                    .foregroundColor(.yellow)
                                            }
                                            
                                            Text(preset.romanNumerals.joined(separator: " → "))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Text(preset.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(spacing: 4) {
                                            Image(systemName: "lock.fill")
                                                .font(.title3)
                                                .foregroundColor(.blue)
                                            Text("Pro")
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        } header: {
                            HStack {
                                Image(systemName: "star.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("Pro Only — Unlock \(proOnlyPresets.count) More Presets")
                                    .fontWeight(.semibold)
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


