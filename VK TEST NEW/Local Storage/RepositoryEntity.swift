import Foundation
import Combine
import SwiftUI
import RealmSwift

class RepositoryEntity: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var repositoryDescription: String?
    @Persisted var avatarURL: String
}

class LocalStorage: LocalStorageProtocol {
    let realm = try! Realm()
    
    func save(repositories: [Repository]) {
        let entities = repositories.map { repo -> RepositoryEntity in
            let entity = RepositoryEntity()
            entity.id = repo.id
            entity.name = repo.name
            entity.repositoryDescription = repo.description
            entity.avatarURL = repo.owner.avatar_url
            return entity
        }
        
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.add(entities, update: .all)
            }
        }
    }
    
    func fetchRepositories() -> [RepositoryEntity] {
        return Array(realm.objects(RepositoryEntity.self))
    }
    
    func delete(ids: [Int]) {
        DispatchQueue.main.async {
            try! self.realm.write {
                let objectsToDelete = self.realm.objects(RepositoryEntity.self).filter("id IN %@", ids)
                self.realm.delete(objectsToDelete)
            }
        }
    }
    
    func update(repository: Repository) {
        DispatchQueue.main.async {
            try! self.realm.write {
                if let entity = self.realm.object(ofType: RepositoryEntity.self, forPrimaryKey: repository.id) {
                    entity.name = repository.name
                    entity.repositoryDescription = repository.description
                    entity.avatarURL = repository.owner.avatar_url
                }
            }
        }
    }
}

