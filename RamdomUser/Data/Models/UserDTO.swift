import Foundation

struct UserDTO: Codable {
    let id: UserID
    let name: UserName
    let email: String
    let phone: String
    let picture: UserPicture
    let gender: String
    let location: UserLocation
    let registered: UserRegistered

    struct UserID: Codable {
        let value: String?
    }

    struct UserName: Codable {
        let first: String
        let last: String
    }

    struct UserPicture: Codable {
        let large: String
        let medium: String
        let thumbnail: String
    }

    struct UserLocation: Codable {
        let street: UserStreet
        let city: String
        let state: String

        struct UserStreet: Codable {
            let name: String
            let number: Int
        }
    }

    struct UserRegistered: Codable {
        let date: String
    }
}

extension UserDTO {
    func toDomain() -> UserDomainModel {
        let formattedDate = ISO8601DateFormatter().date(from: registered.date) ?? Date()

        return UserDomainModel(
            id: id.value ?? UUID().uuidString,
            firstName: name.first,
            lastName: name.last,
            email: email,
            phone: phone,
            picture: picture.large,
            thumbnail: picture.thumbnail,
            gender: gender,
            location: "\(location.street.number) \(location.street.name), \(location.city), \(location.state)",
            registeredDate: formattedDate
        )
    }
}
