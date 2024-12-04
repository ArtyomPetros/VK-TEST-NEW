import Foundation
import Combine
import SwiftUI
import RealmSwift

class APIClient {
    private let baseURL = "https://api.github.com/search/repositories"
    
    func fetchRepositories(query: String, page: Int, sortBy: String = "stars") async throws -> [Repository] {
        guard let url = URL(string: "\(baseURL)?q=\(query)&sort=\(sortBy)&order=asc&page=\(page)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(GitHubResponse.self, from: data)
        return response.items
    }
}
