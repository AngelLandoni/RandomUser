import Foundation

private enum Constants {
    static let pageSize = 40
}

protocol UserRepositoryProtocol {
    func fetchUsers() async throws -> [UserDomainModel]
    func fetchStoredUsers() async -> [UserDomainModel]
    func deleteUser(_ userID: String) async
}

final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let storage: PersistenceStorageProtocol

    private let url = URL(string: "https://randomuser.me/api/?results=\(Constants.pageSize)")!
    
    init(apiClient: APIClientProtocol = APIClient(),
         storage: PersistenceStorageProtocol = CoreDataStorage()) {
        self.apiClient = apiClient
        self.storage = storage
    }
    
    func fetchUsers() async throws -> [UserDomainModel] {
        let response: UserAPIResponse = try await apiClient.fetch(url: url)
        let users = response.results.map { $0.toDomain() }
        
        await storage.saveUsers(users)
        
        return users
    }
    
    func fetchStoredUsers() async -> [UserDomainModel] {
        return await storage.fetchUsers()
    }
    
    func deleteUser(_ userID: String) async {
        await storage.deleteUser(by: userID)
    }
}
