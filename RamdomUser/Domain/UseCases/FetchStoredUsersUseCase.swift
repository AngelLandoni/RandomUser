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
        var uniqueUsers: [UserDomainModel] = []
        
        for user in users {
            guard !seenIDs.contains(user.id) else { continue }
            let isBanned = await repository.isUserBanned(user.id)
            guard !isBanned else { continue }
            
            seenIDs.insert(user.id)
            uniqueUsers.append(user)
        }
        
        return uniqueUsers
    }
}
