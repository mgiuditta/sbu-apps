/// The screens the tool screen pushes.
enum ScannerRoute: Hashable {
    case history
    case creator
    case record(ScanRecord)
    case created(CreatedCode)
}
