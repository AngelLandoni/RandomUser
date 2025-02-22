import Foundation

private enum Constants {
    static let pageSize = 40
    static let baseURL = "https://randomuser.me/api/"
}

protocol UserRepositoryProtocol {
    func fetchUsers() async throws -> [UserDomainModel]
    func fetchStoredUsers() async -> [UserDomainModel]
    func deleteUser(_ userID: String) async
    func banUser(_ userID: String) async
    func isUserBanned(_ userID: String) async -> Bool
}

final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let storage: PersistenceStorageProtocol

    private let url: URL?

    init(
        apiClient: APIClientProtocol = APIClient(),
        storage: PersistenceStorageProtocol = CoreDataStorage()
    ) {
        self.apiClient = apiClient
        self.storage = storage
        self.url = URL(string: "\(Constants.baseURL)?results=\(Constants.pageSize)")
    }
    
    func fetchUsers() async throws -> [UserDomainModel] {
        guard let url = url else { throw URLError(.badURL) }
        
        let response: UserAPIResponse = try await apiClient.fetch(url: url)
        let users = response.results.map { $0.toDomain() }
        
        await storage.saveUsers(users)
        return users
    }
    
    func fetchStoredUsers() async -> [UserDomainModel] {
        await storage.fetchUsers()
    }
    
    func deleteUser(_ userID: String) async {
        await storage.deleteUser(by: userID)
    }
    
    func banUser(_ userID: String) async {
        await storage.banUser(by: userID)
    }
    
    func isUserBanned(_ userID: String) async -> Bool {
        await storage.isUserBanned(by: userID)
    }
}
