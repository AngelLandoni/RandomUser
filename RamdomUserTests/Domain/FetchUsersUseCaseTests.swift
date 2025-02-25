import XCTest
@testable import RamdomUser

@MainActor
final class FetchUsersUseCaseTests: XCTestCase {
    
    private var repositoryMock: MockUserRepository!
    private var fetchUsersUseCase: FetchUsersUseCase!
    
    override func setUp() {
        super.setUp()
        repositoryMock = MockUserRepository()
        fetchUsersUseCase = FetchUsersUseCase(repository: repositoryMock)
    }
    
    override func tearDown() {
        repositoryMock = nil
        fetchUsersUseCase = nil
        super.tearDown()
    }
    
    func testExecute_ShouldReturnFetchedUsers_WhenNoUsersAreBanned() async throws {
        // Given
        let users = [
            UserDomainModel(id: "1", firstName: "John", lastName: "Doe", email: "john.doe@example.com",
                            phone: "+123456789", picture: "https://example.com/john.jpg",
                            thumbnail: "https://example.com/john_thumb.jpg", gender: "Male",
                            location: "New York, USA", registeredDate: Date()),
            UserDomainModel(id: "2", firstName: "Alice", lastName: "Smith", email: "alice.smith@example.com",
                            phone: "+987654321", picture: "https://example.com/alice.jpg",
                            thumbnail: "https://example.com/alice_thumb.jpg", gender: "Female",
                            location: "Los Angeles, USA", registeredDate: Date())
        ]
        repositoryMock.fetchUsersResult = .success(users)
        repositoryMock.isUserBannedResult = false // No users are banned
        
        // When
        let fetchedUsers = try await fetchUsersUseCase.execute()
        
        // Then
        XCTAssertEqual(fetchedUsers.count, users.count, "All fetched users should be returned if none are banned")
    }
    
    func testExecute_ShouldThrowError_WhenRepositoryFails() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: -1, userInfo: nil)
        repositoryMock.fetchUsersResult = .failure(expectedError)
        
        // When & Then
        do {
            _ = try await fetchUsersUseCase.execute()
            XCTFail("Expected an error but did not receive one")
        } catch {
            XCTAssertEqual(error as NSError, expectedError, "Thrown error should match the expected error")
        }
    }
}
