import Foundation

protocol FetchUsersUseCaseProtocol {
    func execute() async throws -> [UserDomainModel]
}

final class FetchUsersUseCase: FetchUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [UserDomainModel] {
        let users = try await repository.fetchUsers()
        var uniqueUsers = Set<UserDomainModel>()
        
        await withTaskGroup(of: (UserDomainModel, Bool).self) { group in
            for user in users {
                group.addTask {
                    let isBanned = await self.repository.isUserBanned(user.id)
                    return (user, isBanned)
                }
            }
            
            for await (user, isBanned) in group {
                if !isBanned {
                    uniqueUsers.insert(user)
                }
            }
        }
        
        return Array(uniqueUsers)
    }
}
