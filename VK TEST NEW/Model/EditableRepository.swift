import Foundation
import Combine
import SwiftUI
import RealmSwift

struct EditableRepository: Identifiable {
    let id: Int
    var repository: Repository
    var isEdited: Bool = false

    init(repository: Repository, isEdited: Bool = false) {
        self.id = repository.id
        self.repository = repository
        self.isEdited = isEdited
    }
}

struct Repository: Decodable, Identifiable {
    let id: Int
    var name: String
    var description: String?
    let owner: Owner
    let stargazers_count: Int

    // Ensure this initializer exists
    init(id: Int, name: String, description: String?, owner: Owner, stargazers_count: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.owner = owner
        self.stargazers_count = stargazers_count
    }
}


struct Owner: Decodable {
    let avatar_url: String
}

struct GitHubResponse: Decodable {
    let items: [Repository]
}
