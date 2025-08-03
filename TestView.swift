import SwiftUI

struct TestView: View {
    enum TestType: String {
        case test = "Test"
    }
    
    @State private var selectedType: TestType? = nil
    
    var body: some View {
        Text("Test")
    }
}