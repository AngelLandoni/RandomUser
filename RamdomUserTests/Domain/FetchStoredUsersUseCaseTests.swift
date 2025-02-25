import XCTest
@testable import RamdomUser

@MainActor
final class FetchStoredUsersUseCaseTests: XCTestCase {
    
    private var repositoryMock: MockUserRepository!
    private var fetchStoredUsersUseCase: FetchStoredUsersUseCase!
    
    override func setUp() {
        super.setUp()
        repositoryMock = MockUserRepository()
        fetchStoredUsersUseCase = FetchStoredUsersUseCase(repository: repositoryMock)
    }
    
    override func tearDown() {
        repositoryMock = nil
        fetchStoredUsersUseCase = nil
        super.tearDown()
    }
    
    func testExecute_ShouldReturnStoredUsers_WhenNoUsersAreBanned() async {
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
        repositoryMock.fetchStoredUsersResult = users
        repositoryMock.isUserBannedResult = false
        
        // When
        let fetchedUsers = await fetchStoredUsersUseCase.execute()
        
        // Then
        XCTAssertEqual(fetchedUsers.count, users.count, "All stored users should be returned if none are banned")
        XCTAssertEqual(fetchedUsers, users, "Fetched users should match stored users")
    }
    
    func testExecute_ShouldFilterOutBannedUsers() async {
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
        repositoryMock.fetchStoredUsersResult = users
        repositoryMock.isUserBannedResult = true
        
        // When
        let fetchedUsers = await fetchStoredUsersUseCase.execute()
        
        // Then
        XCTAssertTrue(fetchedUsers.isEmpty, "No users should be returned if all are banned")
    }
    
    func testExecute_ShouldReturnUniqueUsers() async {
        // Given
        let duplicateUsers = [
            UserDomainModel(id: "1", firstName: "John", lastName: "Doe", email: "john.doe@example.com",
                            phone: "+123456789", picture: "https://example.com/john.jpg",
                            thumbnail: "https://example.com/john_thumb.jpg", gender: "Male",
                            location: "New York, USA", registeredDate: Date()),
            UserDomainModel(id: "1", firstName: "John", lastName: "Doe", email: "john.doe@example.com",
                            phone: "+123456789", picture: "https://example.com/john.jpg",
                            thumbnail: "https://example.com/john_thumb.jpg", gender: "Male",
                            location: "New York, USA", registeredDate: Date()),
            UserDomainModel(id: "2", firstName: "Alice", lastName: "Smith", email: "alice.smith@example.com",
                            phone: "+987654321", picture: "https://example.com/alice.jpg",
                            thumbnail: "https://example.com/alice_thumb.jpg", gender: "Female",
                            location: "Los Angeles, USA", registeredDate: Date())
        ]
        repositoryMock.fetchStoredUsersResult = duplicateUsers
        repositoryMock.isUserBannedResult = false
        
        // When
        let fetchedUsers = await fetchStoredUsersUseCase.execute()
        
        // Then
        XCTAssertEqual(fetchedUsers.count, 2, "Duplicate users should be filtered out")
        XCTAssertEqual(Set(fetchedUsers.map { $0.id }), Set(["1", "2"]), "Only unique users should be returned")
    }
}
