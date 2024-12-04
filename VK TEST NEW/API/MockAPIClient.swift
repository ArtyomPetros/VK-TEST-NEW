import Foundation

class MockAPIClient: APIClientProtocol {
    var repositoriesToReturn: [Repository] = []
    var errorToThrow: Error?

    func fetchRepositories(query: String, page: Int, sortBy: String) async throws -> [Repository] {
        if let error = errorToThrow {
            throw error
        }
        return repositoriesToReturn
    }
}

// MockLocalStorage.swift
import Foundation

class MockLocalStorage: LocalStorageProtocol {
    var savedRepositories: [Repository] = []
    var deletedIds: [Int] = []
    var updatedRepositories: [Repository] = []

    func save(repositories: [Repository]) {
        savedRepositories.append(contentsOf: repositories)
    }

    func fetchRepositories() -> [RepositoryEntity] {
        return []
    }

    func delete(ids: [Int]) {
        deletedIds.append(contentsOf: ids)
    }

    func update(repository: Repository) {
        updatedRepositories.append(repository)
    }
}
