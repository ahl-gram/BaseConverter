import SwiftUI
import UIKit

struct KeyboardDisabledTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.delegate = context.coordinator
        textField.inputView = UIView() // This prevents the system keyboard from showing
        
        // Set tint color to show the caret
        textField.tintColor = .systemBlue
        
        // Add target to detect when editing begins
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidBeginEditing), for: .editingDidBegin)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            // Get cursor position before updating text
            let selectedRange = uiView.selectedTextRange
            
            // Update text
            uiView.text = text
            uiView.placeholder = placeholder
            
            // Try to restore cursor position or put it at the end
            if let selectedRange = selectedRange, uiView.isFirstResponder {
                // If we have a previous position and the field is focused
                if text.count >= (uiView.text?.count ?? 0) {
                    // If text is longer or same length, try to maintain position
                    uiView.selectedTextRange = selectedRange
                } else {
                    // If text is shorter, move to end
                    let newPosition = uiView.endOfDocument
                    uiView.selectedTextRange = uiView.textRange(from: newPosition, to: newPosition)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            self._text = text
        }
        
        @objc func textFieldDidBeginEditing(_ textField: UITextField) {
            // Ensure the caret is visible and at the end of the text
            DispatchQueue.main.async {
                let position = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: position, to: position)
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Since we're using a custom keyboard, this should never be called
            // but we'll handle it just in case
            if let currentText = textField.text,
               let textRange = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: textRange, with: string)
                DispatchQueue.main.async {
                    self.text = updatedText
                }
            }
            return false
        }
    }
} 