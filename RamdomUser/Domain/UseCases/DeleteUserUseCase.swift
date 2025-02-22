import Foundation

protocol DeleteUserUseCaseProtocol {
    func execute(id: String) async
}

final class DeleteUserUseCase: DeleteUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: String) async {
        await repository.deleteUser(id)
        await repository.banUser(id)
    }
}
