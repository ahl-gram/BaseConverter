import SwiftUI
import UIKit

// Custom UITextField subclass that enforces text truncation
class TruncatingTextField: UITextField {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure text is properly truncated
        self.adjustsFontSizeToFitWidth = true
        self.minimumFontSize = 9
        
        // Force text to truncate if needed
        if let text = self.text, !text.isEmpty {
            let size = text.size(withAttributes: self.defaultTextAttributes)
            if size.width > bounds.width - 16 { // Account for insets
                // Force redraw to apply truncation
                self.setNeedsDisplay()
            }
        }
    }
    
    // Override to ensure long text gets truncated
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        // Apply fixed insets to ensure text doesn't expand beyond bounds
        return bounds.insetBy(dx: 8, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        // Apply same insets to editing area
        return bounds.insetBy(dx: 8, dy: 0)
    }
    
    // Prevent text from expanding field
    override var intrinsicContentSize: CGSize {
        // Return a fixed size based on superview if available
        if let superview = self.superview {
            return CGSize(width: superview.bounds.width - 16, height: super.intrinsicContentSize.height)
        }
        return super.intrinsicContentSize
    }
}

struct CustomKeyboardTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = TruncatingTextField()
        textField.placeholder = placeholder
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.delegate = context.coordinator
        textField.inputView = UIView() // This prevents the system keyboard from showing
        
        // Set tint color to show the caret
        textField.tintColor = .systemBlue
        
        // Enable dynamic type for the text field
        textField.adjustsFontForContentSizeCategory = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        
        // Configure text field for better handling of long text
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 9
        textField.textAlignment = .left
        
        // Configure for text truncation
        textField.allowsEditingTextAttributes = false
        
        // Use line truncation through NSParagraphStyle
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        textField.defaultTextAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        
        // Configure scrolling behavior for long content
        textField.clearsOnBeginEditing = false
        textField.clearButtonMode = .never
        textField.rightViewMode = .never // Ensure no decorations on the right side
        textField.leftViewMode = .never // Ensure no decorations on the left side
        
        // Add target to detect when editing begins
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidBeginEditing), for: .editingDidBegin)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            // Store the current text length for comparison
            let oldLength = uiView.text?.count ?? 0
            let newLength = text.count
            
            // Update text and placeholder
            uiView.text = text
            uiView.placeholder = placeholder
            
            // Properly position cursor based on text change
            if uiView.isFirstResponder {
                if newLength > oldLength {
                    // Text was added - move cursor to the end and ensure it's visible
                    let newPosition = uiView.endOfDocument
                    uiView.selectedTextRange = uiView.textRange(from: newPosition, to: newPosition)
                    
                    // For UITextField, simply setting the cursor position is enough
                    // as it will automatically scroll to show the cursor
                } else if newLength < oldLength {
                    // Text was deleted - move cursor to the end
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