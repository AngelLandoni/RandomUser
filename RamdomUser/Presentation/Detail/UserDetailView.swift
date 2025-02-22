import SwiftUI

struct UserDetailView: View {
    let user: UserPresentationModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: user.picture)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text("Name: \(user.name) \(user.surname)")
                .font(.title2)
            Text("Gender: \(user.gender)")
            Text("Email: \(user.email)")
            Text("Location: \(user.location)")
            Text("Registered: \(user.regsiteredDate)")
            Spacer()
        }
        .padding()
        .navigationTitle("\(user.name) \(user.surname)")
    }
}
