import XCTest
import CoreData
@testable import RamdomUser

class CoreDataStorageTests: XCTestCase {
    var storage: CoreDataStorage!
    var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        
        container = NSPersistentContainer(name: "RamdomUser")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load in-memory store: \(error?.localizedDescription ?? "")")
        }
        
        storage = CoreDataStorage(container: container)
    }

    override func tearDown() {
        storage = nil
        container = nil
        super.tearDown()
    }

    func testSaveUsers() async {
        // Given
        let user = UserDomainModel(
            id: "1",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "123-456-7890",
            picture: "pic.jpg",
            thumbnail: "thumb.jpg",
            gender: "male",
            location: "New York",
            registeredDate: Date()
        )
        let users = [user]

        // When
        await storage.saveUsers(users)

        // Then
        let fetchedUsers = await storage.fetchUsers()
        XCTAssertEqual(fetchedUsers.count, 1)
        XCTAssertEqual(fetchedUsers[0].id, "1")
        XCTAssertEqual(fetchedUsers[0].firstName, "John")
        XCTAssertEqual(fetchedUsers[0].lastName, "Doe")
    }

    func testSaveUsers_DuplicatesIgnored() async {
        // Given
        let user = UserDomainModel(
            id: "1",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "123-456-7890",
            picture: "pic.jpg",
            thumbnail: "thumb.jpg",
            gender: "male",
            location: "Barcelona",
            registeredDate: Date()
        )
        let updatedUser = UserDomainModel(
            id: "1",
            firstName: "Jane",
            lastName: "Doe",
            email: "jane.doe@example.com",
            phone: "098-765-4321",
            picture: "newpic.jpg",
            thumbnail: "newthumb.jpg",
            gender: "female",
            location: "Los Angeles",
            registeredDate: Date()
        )

        // When
        await storage.saveUsers([user])
        await storage.saveUsers([updatedUser])

        // Then
        let fetchedUsers = await storage.fetchUsers()
        XCTAssertEqual(fetchedUsers.count, 1)
        XCTAssertEqual(fetchedUsers[0].firstName, "John")
    }

    // MARK: - Test fetchUsers
    func testFetchUsers_EmptyStore() async {
        // When
        let fetchedUsers = await storage.fetchUsers()

        // Then
        XCTAssertTrue(fetchedUsers.isEmpty)
    }

    // MARK: - Test deleteUser
    func testDeleteUser() async {
        // Given
        let user = UserDomainModel(
            id: "1",
            firstName: "John",
            lastName: "Smith",
            email: "john@google.com",
            phone: "123456789",
            picture: "",
            thumbnail: "",
            gender: "Male",
            location: "USA",
            registeredDate: Date()
        )
                
        await storage.saveUsers([user])

        // When
        await storage.deleteUser(by: "1")

        // Then
        let fetchedUsers = await storage.fetchUsers()
        XCTAssertTrue(fetchedUsers.isEmpty)
    }

    func testDeleteUser_NonExistent() async {
        // When
        await storage.deleteUser(by: "999")

        // Then
        let fetchedUsers = await storage.fetchUsers()
        XCTAssertTrue(fetchedUsers.isEmpty)
    }

    func testBanUser() async {
        // When
        await storage.banUser(by: "1")

        // Then
        let isBanned = await storage.isUserBanned(by: "1")
        XCTAssertTrue(isBanned)
    }

    func testBanUser_DuplicateBan() async {
        // When
        await storage.banUser(by: "1")
        await storage.banUser(by: "1")

        // Then
        let isBanned = await storage.isUserBanned(by: "1")
        XCTAssertTrue(isBanned)
        // ONly one banned user exist.
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<BannedUserEntity> = BannedUserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", "1")
        let count = try? context.count(for: fetchRequest)
        XCTAssertEqual(count, 1)
    }

    func testIsUserBanned_NotBanned() async {
        // When
        let isBanned = await storage.isUserBanned(by: "999")

        // Then
        XCTAssertFalse(isBanned)
    }
}
