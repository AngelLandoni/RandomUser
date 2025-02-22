import SwiftUI

struct LoadingUsersError: View {
    var retry: () -> Void
    
    var body: some View {
        VStack {
            Text("Error loading users")
            Button("Retry") {
                retry()
            }
        }
    }
}
