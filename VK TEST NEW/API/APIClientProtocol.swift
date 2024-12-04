
import Foundation

protocol APIClientProtocol {
    func fetchRepositories(query: String, page: Int, sortBy: String) async throws -> [Repository]
}
