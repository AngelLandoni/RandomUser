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
    @Published var errorLoadingUsers = false
    @Published var errorLoadingExtraUsers = false
    
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
            syncFilteredUsers()
        } catch {
            errorLoadingUsers = true
        }
        isLoadingFirstTime = false
    }
    
    func scrollReachedBottom() async {
        
    }
    
    func deleteUser(user: UserPresentationModel) {}
    
    func onNewCellAppear(userID: String) {
        guard userID == filteredUsers.last?.id else { return }

        Task.detached {
            await self.loadExtraUsers()
        }
    }
    
    func retryLoadExtraUsers() async {
        errorLoadingExtraUsers = false
        await self.loadExtraUsers()
    }
    
    private func syncFilteredUsers() {
        self.filteredUsers = self.users
    }
    
    private func loadExtraUsers() async {
        do {
            let users = try await fetchUsersUseCase.execute()
            self.users += users.map { $0.toPresentation() }
            syncFilteredUsers()
        } catch {
            errorLoadingExtraUsers = true
        }
    }
    
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
