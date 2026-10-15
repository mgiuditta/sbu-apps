import SwiftUI

/// A menu picker, or a list of its own at the accessibility sizes, where the menu cut "Personalizzato".
struct PeriodPickerStyle: ViewModifier {
    let isAccessibilitySize: Bool

    func body(content: Content) -> some View {
        if isAccessibilitySize {
            content.pickerStyle(.navigationLink)
        } else {
            content.pickerStyle(.menu)
        }
    }
}
