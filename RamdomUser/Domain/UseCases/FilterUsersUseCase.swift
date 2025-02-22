protocol FilterUsersUseCaseProtocol {
    func execute(users: [UserDomainModel], searchText: String) async throws -> [UserDomainModel]
}

final class FilterUsersUseCase: FilterUsersUseCaseProtocol {
    func execute(users: [UserDomainModel], searchText: String) -> [UserDomainModel] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { user in
            user.firstName.lowercased().contains(searchText.lowercased()) ||
            user.lastName.lowercased().contains(searchText.lowercased()) ||
            user.email.lowercased().contains(searchText.lowercased())
        }
    }
}
