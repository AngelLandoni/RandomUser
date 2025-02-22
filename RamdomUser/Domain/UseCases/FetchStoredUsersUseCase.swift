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
        
        await withTaskGroup(of: (UserDomainModel, Bool).self) { group in
            for user in users {
                guard !seenIDs.contains(user.id) else { continue }
                seenIDs.insert(user.id)
                
                group.addTask {
                    let isBanned = await self.repository.isUserBanned(user.id)
                    return (user, isBanned)
                }
            }
            
            for await (user, isBanned) in group {
                if !isBanned {
                    uniqueUsers.append(user)
                }
            }
        }
        
        return uniqueUsers
    }
}
