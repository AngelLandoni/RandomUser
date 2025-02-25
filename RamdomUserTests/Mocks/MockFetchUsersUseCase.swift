import XCTest
import Combine
@testable import RamdomUser

final class MockFetchUsersUseCase: FetchUsersUseCaseProtocol {
    var result: [UserDomainModel] = []
    var wasCalled = false
    
    func execute() async throws -> [UserDomainModel] {
        wasCalled = true
        return result
    }
}
