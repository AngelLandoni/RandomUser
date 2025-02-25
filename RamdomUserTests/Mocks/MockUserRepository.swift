import XCTest
@testable import RamdomUser

final class MockUserRepository: UserRepositoryProtocol {
    var fetchUsersResult: Result<[UserDomainModel], Error> = .success([])
    var fetchStoredUsersResult: [UserDomainModel] = []
    var deleteUserCalledWithID: String?
    var banUserCalledWithID: String?
    var isUserBannedResult: Bool = false
    
    func fetchUsers() async throws -> [UserDomainModel] {
        switch fetchUsersResult {
        case .success(let users):
            return users
        case .failure(let error):
            throw error
        }
    }
    
    func fetchStoredUsers() async -> [UserDomainModel] {
        return fetchStoredUsersResult
    }
    
    func deleteUser(_ userID: String) async {
        deleteUserCalledWithID = userID
    }
    
    func banUser(_ userID: String) async {
        banUserCalledWithID = userID
    }
    
    func isUserBanned(_ userID: String) async -> Bool {
        return isUserBannedResult
    }
}
