import SwiftUI

enum TestType: String {
    case test = "Test"
}

struct TestView: View {
    @State private var selectedType: TestType? = nil
    
    var body: some View {
        Text("Test")
    }
}