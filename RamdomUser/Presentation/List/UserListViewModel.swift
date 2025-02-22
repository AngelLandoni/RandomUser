import Foundation

@MainActor
class UserListViewModel: ObservableObject {
    @Published var users: [UserPresentationModel] = []
    @Published var searchText: String = ""
    
    var filteredUsers: [UserPresentationModel] {
        guard !users.isEmpty else {
            return users
        }
        
        return users.filter { user in
            user.name.lowercased().contains(searchText.lowercased()) ||
            user.surname.lowercased().contains(searchText.lowercased())
        }
    }
    
    init() {
    }
    
    func scrollReachedBottom() async {}
    
    func deleteUser(user: UserPresentationModel) {}
}
