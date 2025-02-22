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
        return Array(Set(users))
    }
}
