import XCTest
@testable import RamdomUser

final class MockFetchStoredUsersUseCase: FetchStoredUsersUseCaseProtocol {
    var result: [UserDomainModel] = []
    
    func execute() async -> [UserDomainModel] {
        return result
    }
}
