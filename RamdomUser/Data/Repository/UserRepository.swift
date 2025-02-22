import Foundation

protocol UserRepositoryProtocol {
    func fetchUsers() async throws -> [UserDomainModel]
    func deleteUser(_ userID: String) async
}

final class UserRepository: UserRepositoryProtocol {
    func fetchUsers() async throws -> [UserDomainModel] {
        let dummyUserDTO = UserDTO(
            id: UserDTO.UserID(value: "12345"),
            name: UserDTO.UserName(first: "John", last: "Doe"),
            email: "johndoe@example.com",
            phone: "+1 234 567 890",
            picture: UserDTO.UserPicture(
                large: "https://randomuser.me/api/portraits/men/1.jpg",
                medium: "https://randomuser.me/api/portraits/med/men/1.jpg",
                thumbnail: "https://randomuser.me/api/portraits/thumb/men/1.jpg"
            ),
            gender: "male",
            location: UserDTO.UserLocation(
                street: UserDTO.UserLocation.UserStreet(name: "Main St", number: 123),
                city: "New York",
                state: "NY"
            ),
            registered: UserDTO.UserRegistered(date: "2020-01-01T12:34:56Z") // ISO 8601 format
        )
        
        return [dummyUserDTO.toDomain()]
    }
    
    func deleteUser(_ userID: String) async {
    }
}
