import Foundation

protocol FetchStoredUsersUseCaseProtocol {
    func execute() async -> [UserDomainModel]
}

final class FetchStoredUsersUseCase: FetchStoredUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async -> [UserDomainModel] {
        let users = await repository.fetchStoredUsers()
        
        var seenIDs = Set<String>()
        let uniqueUsers = users.filter { user in
            guard !seenIDs.contains(user.id) else { return false }
            seenIDs.insert(user.id)
            return true
        }
        
        return uniqueUsers
    }
}
