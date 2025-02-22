import Foundation

extension UserEntity {
    func toDomain() -> UserDomainModel {
        return UserDomainModel(
            id: id ?? UUID().uuidString,
            firstName: name ?? "",
            lastName: surname ?? "",
            email: email ?? "",
            phone: phone ?? "",
            picture: picture ?? "",
            thumbnail: thumbnail ?? "",
            gender: gender ?? "",
            location: location ?? "",
            registeredDate: registeredDate ?? Date()
        )
    }
}
