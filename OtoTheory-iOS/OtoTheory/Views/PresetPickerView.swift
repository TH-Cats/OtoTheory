import SwiftUI

struct PresetPickerView: View {
    @Binding var selectedKey: String
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Preset) -> Void
    
    @State private var selectedCategory: PresetCategory = .pop
    
    private let keys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
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
                    ForEach(Preset.byCategory(selectedCategory)) { preset in
                        Button(action: {
                            onSelect(preset)
                        }) {
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
                            .padding(.vertical, 4)
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
        }
    )
}


