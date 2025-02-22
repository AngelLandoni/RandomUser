import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        NavigationView {
            if viewModel.isLoadingFirstTime {
                ProgressView("Loading users...")
            } else if viewModel.errorLoadingUsers {
                LoadingUsersError {
                    Task.detached {
                        await viewModel.initialLoad()
                    }
                }
            } else {
                List {
                    ForEach(viewModel.filteredUsers) { user in
                        NavigationLink(destination: UserDetailView(user: user)) {
                            UserRow(name: user.name, surname: user.surname, picture: user.thumbnail)
                        }
                        .onAppear {
                            viewModel.onNewCellAppear(userID: user.id)
                        }
                    }
                    .onDelete { index in
                        Task.detached {
                            await viewModel.deleteUser(index: index)
                        }
                    }
                    
                    if viewModel.errorLoadingExtraUsers {
                        LoadingUsersError {
                            Task.detached {
                                await viewModel.retryLoadExtraUsers()
                            }
                        }
                    } else if viewModel.shouldShowLoadingRow {
                        Text("Loading")
                    }
                }
                .searchable(text: $viewModel.searchText, prompt: "Search by name, surname, or email")
                .navigationTitle("Users")
            }
        }
        .task {
            await viewModel.initialLoad()
        }
    }
}

private struct UserRow: View {
    let name: String
    let surname: String
    let picture: String
    
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
        }
    }
}
