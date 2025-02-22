import Foundation
import Combine

private enum Constants {
    static let searchDebounce = 500
}

@MainActor
class UserListViewModel: ObservableObject {
    @Published var filteredUsers: [UserPresentationModel] = []
    @Published var searchText: String = ""
    @Published var isLoadingFirstTime = false
    
    var users: [UserPresentationModel] = []

    private let fetchUsersUseCase: FetchUsersUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchUsersUseCase: FetchUsersUseCaseProtocol = FetchUsersUseCase(repository: UserRepository())
    ) {
        self.fetchUsersUseCase = fetchUsersUseCase
        setupSearchListener()
    }
    
    func initialLoad() async {
        isLoadingFirstTime = true
        do {
            let users = try await fetchUsersUseCase.execute()
            self.users = users.map { $0.toPresentation() }
            self.filteredUsers = self.users
        } catch {
            print("Error fetching users: \(error)")
        }
        isLoadingFirstTime = false
    }
    
    func scrollReachedBottom() async { }
    
    func deleteUser(user: UserPresentationModel) {}
    
    private func setupSearchListener() {
        $searchText
            .debounce(for: .milliseconds(Constants.searchDebounce), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                
                if self.searchText.isEmpty {
                    filteredUsers = self.users
                    return
                }
                                
                filteredUsers = users.filter { user in
                    user.name.lowercased().contains(self.searchText.lowercased()) ||
                    user.surname.lowercased().contains(self.searchText.lowercased())
                }
            }
            .store(in: &cancellables)
    }
}
