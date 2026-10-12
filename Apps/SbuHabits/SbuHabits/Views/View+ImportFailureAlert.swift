import SwiftUI

extension View {
    /// Shows what is wrong with an imported file and what to do, while `failure` is set.
    func importFailureAlert(_ failure: Binding<HabitsImport.Failure?>) -> some View {
        let isPresented = Binding {
            failure.wrappedValue != nil
        } set: { isPresented in
            if isPresented == false {
                failure.wrappedValue = nil
            }
        }
        return alert(Text(failure.wrappedValue?.title ?? ""), isPresented: isPresented, presenting: failure.wrappedValue) { _ in
            // No actions: the system adds its own OK.
        } message: { failure in
            Text(failure.message)
        }
    }
}
