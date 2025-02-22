import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.filteredUsers) { user in
                    NavigationLink(destination: UserDetailView(user: user)) {
                        UserRow(name: user.name, surname: user.surname, picture: user.picture) {
                            viewModel.deleteUser(user: user)
                        }
                    }
                    .onAppear {
                        if user.id == viewModel.filteredUsers.last?.id {
                            Task.detached {
                                await viewModel.scrollReachedBottom()
                            }
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search by name, surname, or email")
            .navigationTitle("Users")
        }
    }
}

private struct UserRow: View {
    let name: String
    let surname: String
    let picture: String
    
    let onDelete: () -> Void

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: picture)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text("\(name) \(surname)")
                    .font(.headline)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}
