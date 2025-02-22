import Foundation

protocol APIClientProtocol {
    func fetch<T: Decodable>(url: URL) async throws -> T
}

final class APIClient: APIClientProtocol {
    func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
