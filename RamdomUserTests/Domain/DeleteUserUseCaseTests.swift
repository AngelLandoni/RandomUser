import XCTest
@testable import RamdomUser

@MainActor
final class DeleteUserUseCaseTests: XCTestCase {
    
    private var repositoryMock: MockUserRepository!
    private var deleteUserUseCase: DeleteUserUseCase!

    override func setUp() {
        super.setUp()
        repositoryMock = MockUserRepository()
        deleteUserUseCase = DeleteUserUseCase(repository: repositoryMock)
    }

    override func tearDown() {
        repositoryMock = nil
        deleteUserUseCase = nil
        super.tearDown()
    }
    
    func testExecute_ShouldCallDeleteAndBanUser() async {
        // Given
        let userID = "12345"
        
        // When
        await deleteUserUseCase.execute(id: userID)
        
        // Then
        XCTAssertEqual(repositoryMock.deleteUserCalledWithID, userID, "deleteUser should be called with correct ID")
        XCTAssertEqual(repositoryMock.banUserCalledWithID, userID, "banUser should be called with correct ID")
    }
}
