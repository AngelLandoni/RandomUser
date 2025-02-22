import Foundation

struct UserDomainModel: Hashable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let picture: String
    let thumbnail: String
    let gender: String
    let location: String
    let registeredDate: Date
}

extension UserDomainModel {
    func toPresentation() -> UserPresentationModel {
        let formattedDate = DateFormatter.localizedString(from: self.registeredDate, dateStyle: .medium, timeStyle: .none)
        
        return UserPresentationModel(
            id: self.id,
            name: self.firstName,
            surname: self.lastName,
            picture: self.picture,
            thumbnail: self.thumbnail,
            gender: self.gender.capitalized,
            location: formattedDate,
            regsiteredDate: self.location,
            email: self.email
        )
    }
}

