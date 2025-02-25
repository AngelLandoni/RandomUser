import XCTest
import Combine
@testable import RamdomUser

class UserListViewModelTests: XCTestCase {
    var viewModel: UserListViewModel!
    var fetchUsersUseCaseMock: MockFetchUsersUseCase!
    var fetchStoredUsersUseCaseMock: MockFetchStoredUsersUseCase!
    var deleteUserUseCaseMock: MockDeleteUserUseCase!
    var cancellables: Set<AnyCancellable> = []
    
    @MainActor override func setUp() {
        super.setUp()
        fetchUsersUseCaseMock = MockFetchUsersUseCase()
        fetchStoredUsersUseCaseMock = MockFetchStoredUsersUseCase()
        deleteUserUseCaseMock = MockDeleteUserUseCase()
        
        viewModel = UserListViewModel(
            fetchUsersUseCase: fetchUsersUseCaseMock,
            fetchStoredUsersUseCase: fetchStoredUsersUseCaseMock,
            deleteUserUseCase: deleteUserUseCaseMock
        )
    }
    
    override func tearDown() {
        viewModel = nil
        fetchUsersUseCaseMock = nil
        fetchStoredUsersUseCaseMock = nil
        deleteUserUseCaseMock = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    @MainActor func testInitialLoad_WithStoredUsers_ShouldSetFilteredUsers() async {
        // Given
        let storedUsers = [
            UserDomainModel(
                id: "1",
                firstName: "John",
                lastName: "Doe",
                email: "john.doe@example.com",
                phone: "+123456789",
                picture: "https://example.com/john_doe.jpg",
                thumbnail: "https://example.com/john_doe_thumb.jpg",
                gender: "Male",
                location: "New York, USA",
                registeredDate: Date(timeIntervalSince1970: 1620000000)
            )
        ]
        fetchStoredUsersUseCaseMock.result = storedUsers
        
        // When
        await viewModel.initialLoad()
        
        // Then
        XCTAssertEqual(viewModel.filteredUsers.count, 1)
        XCTAssertEqual(viewModel.filteredUsers.first?.name, "John")
    }
    
    @MainActor func testInitialLoad_NoStoredUsers_ShouldFetchExtraUsers() async {
        // Given
        fetchStoredUsersUseCaseMock.result = []
        let fetchedUsers = [
            UserDomainModel(
                id: "2",
                firstName: "Alice",
                lastName: "Smith",
                email: "alice.smith@example.com",
                phone: "+987654321",
                picture: "https://example.com/alice_smith.jpg",
                thumbnail: "https://example.com/alice_smith_thumb.jpg",
                gender: "Female",
                location: "Los Angeles, USA",
                registeredDate: Date(timeIntervalSince1970: 1605000000)
            )
        ]
        fetchUsersUseCaseMock.result = fetchedUsers
        
        // When
        await viewModel.initialLoad()
        
        // Then
        XCTAssertEqual(viewModel.filteredUsers.count, 1)
        XCTAssertEqual(viewModel.filteredUsers.first?.name, "Alice")
    }
    
    @MainActor func testDeleteUser_ShouldRemoveUserFromList() async {
        // Given
        let john = UserDomainModel(
            id: "1",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "+123456789",
            picture: "https://example.com/john_doe.jpg",
            thumbnail: "https://example.com/john_doe_thumb.jpg",
            gender: "Male",
            location: "New York, USA",
            registeredDate: Date(timeIntervalSince1970: 1620000000)
        )
        let alice = UserDomainModel(
            id: "2",
            firstName: "Alice",
            lastName: "Smith",
            email: "alice.smith@example.com",
            phone: "+987654321",
            picture: "https://example.com/alice_smith.jpg",
            thumbnail: "https://example.com/alice_smith_thumb.jpg",
            gender: "Female",
            location: "Los Angeles, USA",
            registeredDate: Date(timeIntervalSince1970: 1605000000)
        )
        fetchStoredUsersUseCaseMock.result = [john, alice]
        await viewModel.initialLoad()
        
        // When
        await viewModel.deleteUser(index: IndexSet(integer: 0))
        
        // Then
        XCTAssertEqual(viewModel.filteredUsers.count, 1)
        XCTAssertEqual(viewModel.filteredUsers.first?.name, "Alice")
    }
    
    @MainActor func testSearchTextFiltering_ShouldFilterUsers() async {
        // Given
        let john = UserDomainModel(
            id: "1",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "+123456789",
            picture: "https://example.com/john_doe.jpg",
            thumbnail: "https://example.com/john_doe_thumb.jpg",
            gender: "Male",
            location: "New York, USA",
            registeredDate: Date(timeIntervalSince1970: 1620000000)
        )
        let alice = UserDomainModel(
            id: "2",
            firstName: "Alice",
            lastName: "Smith",
            email: "alice.smith@example.com",
            phone: "+987654321",
            picture: "https://example.com/alice_smith.jpg",
            thumbnail: "https://example.com/alice_smith_thumb.jpg",
            gender: "Female",
            location: "Los Angeles, USA",
            registeredDate: Date(timeIntervalSince1970: 1605000000)
        )
        fetchStoredUsersUseCaseMock.result = [john, alice]
        await viewModel.initialLoad()
        
        let expectation = XCTestExpectation(description: "Wait for search debounce")
        
        // Observe changes to filteredUsers
        let cancellable = viewModel.$filteredUsers
            .dropFirst() // Ignore the initial value
            .sink { _ in
                expectation.fulfill()
            }
        
        // When
        viewModel.searchText = "John"
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        cancellable.cancel() // Cleanup
        
        XCTAssertEqual(viewModel.filteredUsers.count, 1)
        XCTAssertEqual(viewModel.filteredUsers.first?.name, "John")
    }
    
    @MainActor
    func testRetryLoadExtraUsers_ShouldResetErrorAndFetchUsers() async {
        // Given
        viewModel.errorLoadingExtraUsers = true
        let fetchedUsers = [UserDomainModel(
            id: "3",
            firstName: "Bob",
            lastName: "Brown",
            email: "bob.brown@example.com",
            phone: "+1122334455",
            picture: "https://example.com/bob_brown.jpg",
            thumbnail: "https://example.com/bob_brown_thumb.jpg",
            gender: "Male",
            location: "London, UK",
            registeredDate: Date(timeIntervalSince1970: 1580000000)
        )]
        fetchUsersUseCaseMock.result = fetchedUsers
        
        let expectation = XCTestExpectation(description: "Wait for error reset and user load")
        
        let cancellable = viewModel.$filteredUsers
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
        
        // When
        viewModel.retryLoadExtraUsers()
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        cancellable.cancel() // Cleanup
        
        XCTAssertFalse(viewModel.errorLoadingExtraUsers)
        XCTAssertEqual(viewModel.filteredUsers.count, 1)
        XCTAssertEqual(viewModel.filteredUsers.first?.name, "Bob")
    }
    
}
