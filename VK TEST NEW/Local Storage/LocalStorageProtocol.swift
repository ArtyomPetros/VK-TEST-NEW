import Foundation

protocol LocalStorageProtocol {
    func save(repositories: [Repository])
    func fetchRepositories() -> [RepositoryEntity]
    func delete(ids: [Int])
    func update(repository: Repository)
}
