import SwiftUI

struct AboutView: View {
    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) private var dismiss
    
    // App version and build information
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "Base Converter v\(version) (\(build))"
    }
    
    // Define colors for each base (matching ContentView)
    private let baseColors = [
        "Binary": Color.blue,
        "Decimal": Color.green,
        "Duodecimal": Color.purple,
        "Hexadecimal": Color.orange
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section() {
                    Text(appVersion)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 6)
                }
                
                Section(header: Text("Description").font(.subheadline)) {
                    Text("Base Converter is a utility app for converting numbers between different numeral systems. Numeral systems represent values using different sets of symbols, with each system using a specific number as its 'base'. Understanding different numeral systems is fundamental in computing, mathematics, and many scientific fields.")
                        .padding(.bottom, 10)
                    
                    Text("Supported numeral systems:")
                        .font(.subheadline)
                        .bold()
                        .padding(.bottom, 8)
                    
                    // Base 2 (Binary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Binary (Base 2)")
                            .bold()
                            .foregroundColor(baseColors["Binary"])
                        Text("Uses only 0 and 1. The foundation of digital computing.")
                            .padding(.leading, 16)
                    }
                    .padding(.bottom, 8)
                    
                    // Base 10 (Decimal)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Decimal (Base 10)")
                            .bold()
                            .foregroundColor(baseColors["Decimal"])
                        Text("Our standard counting system with digits 0-9.")
                            .padding(.leading, 16)
                    }
                    .padding(.bottom, 8)
                    
                    // Base 12 (Duodecimal)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duodecimal (Base 12)")
                            .bold()
                            .foregroundColor(baseColors["Duodecimal"])
                        Text("Uses 0-9, X (for 10), and E (for 11). Useful for fractions and divisibility.")
                            .padding(.leading, 16)
                    }
                    .padding(.bottom, 8)
                    
                    // Base 16 (Hexadecimal)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hexadecimal (Base 16)")
                            .bold()
                            .foregroundColor(baseColors["Hexadecimal"])
                        Text("Uses 0-9 and A-F. Common in computing for representing binary data compactly.")
                            .padding(.leading, 16)
                    }
                }
                
                Section(header: Text("Features").font(.subheadline)) {
                    // Feature 1: Real-time conversion
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.green)
                                .frame(width: 20, alignment: .center)
                            Text("Real-time conversion between all number bases")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Feature 2: Context-aware keyboard
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "keyboard")
                                .foregroundColor(.green)
                                .frame(width: 20, alignment: .center)
                            Text("Context-aware keyboard that shows only valid digits for each base")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Feature 3: Increment/decrement buttons
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.green)
                                .frame(width: 20, alignment: .center)
                            Text("Increment/decrement buttons for easy value adjustments")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Feature 4: Negative numbers
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "plusminus")
                                .foregroundColor(.green)
                                .frame(width: 20, alignment: .center)
                            Text("Support for negative numbers across all bases")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Feature 5: Accessibility
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "accessibility")
                                .foregroundColor(.green)
                                .frame(width: 20, alignment: .center)
                            Text("Accessible design with dynamic type support")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Copyright section - no header
                Section() {
                    Text("© 2025 Alexander Lee - Route 12B Software")
                        .font(.caption)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 6)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("About")
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