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
        return Array(Set(users))
    }
}
