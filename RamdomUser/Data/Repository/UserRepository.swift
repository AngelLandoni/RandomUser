import Foundation

private enum Constants {
    static let pageSize = 40
}

protocol UserRepositoryProtocol {
    func fetchUsers() async throws -> [UserDomainModel]
    func deleteUser(_ userID: String) async
}

final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let url = URL(string: "https://randomuser.me/api/?results=\(Constants.pageSize)")!
    
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchUsers() async throws -> [UserDomainModel] {
        let response: UserAPIResponse = try await apiClient.fetch(url: url)
        return response.results.map { $0.toDomain() }
    }
    
    func deleteUser(_ userID: String) async {
    }
}
