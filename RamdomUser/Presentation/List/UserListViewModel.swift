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
    
    private var users: [UserPresentationModel] = []

    private let fetchUsersUseCase: FetchUsersUseCaseProtocol
    private let fetchStoredUsersUseCase: FetchStoredUsersUseCaseProtocol

    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchUsersUseCase: FetchUsersUseCaseProtocol = FetchUsersUseCase(repository: UserRepository()),
        fetchStoredUsersUseCase: FetchStoredUsersUseCaseProtocol = FetchStoredUsersUseCase(repository: UserRepository())
    ) {
        self.fetchUsersUseCase = fetchUsersUseCase
        self.fetchStoredUsersUseCase = fetchStoredUsersUseCase
        setupSearchListener()
    }
    
    func initialLoad() async {
        isLoadingFirstTime = true
        
        let storedUsers = await fetchStoredUsersUseCase.execute()
        if storedUsers.isEmpty {
            await loadExtraUsers()
        } else {
            users = storedUsers.map { $0.toPresentation() }
            syncFilteredUsers()
        }
        
        isLoadingFirstTime = false
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
