import SwiftUI

struct AboutView: View {
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) private var dismiss
    
    // App version and build information
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "Version \(version) (\(build))"
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Version").font(.headline)) {
                    Text(appVersion)
                        .padding(.vertical, 6)
                }
                
                Section(header: Text("Description").font(.headline)) {
                    Text("Base Converter is a utility app for converting numbers between different numeral systems.")
                        .padding(.bottom, 10)
                    
                    Text("Supported numeral systems:")
                        .font(.subheadline)
                        .bold()
                        .padding(.bottom, 8)
                    
                    // Base 2 (Binary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Binary (Base 2)")
                            .bold()
                        Text("Uses only 0 and 1. The foundation of digital computing.")
                            .padding(.leading, 16)
                    }
                    .padding(.bottom, 8)
                    
                    // Base 10 (Decimal)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Decimal (Base 10)")
                            .bold()
                        Text("Our standard counting system with digits 0-9.")
                            .padding(.leading, 16)
                    }
                    .padding(.bottom, 8)
                    
                    // Base 12 (Duodecimal)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Duodecimal (Base 12)")
                            .bold()
                        Text("Uses 0-9, X (for 10), and E (for 11). Useful for fractions and divisibility.")
                            .padding(.leading, 16)
                    }
                    .padding(.bottom, 8)
                    
                    // Base 16 (Hexadecimal)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Hexadecimal (Base 16)")
                            .bold()
                        Text("Uses 0-9 and A-F. Common in computing for representing binary data compactly.")
                            .padding(.leading, 16)
                    }
                }
                
                Section(header: Text("Features").font(.headline)) {
                    ForEach([
                        "Real-time conversion between all number bases",
                        "Context-aware keyboard that shows only valid digits for each base",
                        "Increment/decrement buttons for easy value adjustments",
                        "Support for negative numbers across all bases",
                        "Accessible design with dynamic type support"
                    ], id: \.self) { feature in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(.body)
                                Text(feature)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("About Base Converter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(.gray)
                }
            }
        }
    }
}

#Preview {
    AboutView()
} 