import XCTest
@testable import RamdomUser

final class MockDeleteUserUseCase: DeleteUserUseCaseProtocol {
    var wasCalled = false
    var lastDeletedId: String?
    
    func execute(id: String) async {
        wasCalled = true
        lastDeletedId = id
    }
}
