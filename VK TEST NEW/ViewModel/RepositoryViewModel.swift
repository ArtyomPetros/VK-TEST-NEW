import Foundation
import Combine
import SwiftUI
import RealmSwift

class RepositoryViewModel: ObservableObject {
    @Published var editableRepositories: [EditableRepository] = []
    @Published var isLoading = false
    @Published var errorMessage: IdentifiableError?
    @Published var sortBy: String = "all"
    @Published var hasReachedEnd = false
    private let itemsPerPage = 60

    private let apiClient: APIClientProtocol
    private let localStorage: LocalStorageProtocol
    private var currentPage = 1

    init(apiClient: APIClientProtocol = APIClient(), localStorage: LocalStorageProtocol = LocalStorage()) {
        self.apiClient = apiClient
        self.localStorage = localStorage
    }
    func getFilteredRepositories() -> [EditableRepository] {
            switch sortBy {
            case "edited":
                return editableRepositories.filter { $0.isEdited }
            case "all":
                return editableRepositories
            default:
                return editableRepositories.sorted { $0.repository.name < $1.repository.name }
            }
        }

        func updateRepository(at index: Int, with newValue: EditableRepository) {
         
            if let actualIndex = editableRepositories.firstIndex(where: { $0.id == newValue.id }) {
                editableRepositories[actualIndex] = newValue
            }
        }
    
    var filteredRepositories: [EditableRepository] {
        switch sortBy {
        case "edited":
            return editableRepositories.filter { $0.isEdited }
        case "all":
            return editableRepositories
        default:
            return editableRepositories.sorted { $0.repository.name < $1.repository.name }
        }
    }
    


    
    func loadMoreContentIfNeeded(currentItem: EditableRepository?) async {
            guard let currentItem = currentItem else {
                return
            }
            
            let thresholdIndex = editableRepositories.index(editableRepositories.endIndex, offsetBy: -5)
            if editableRepositories.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
                await loadRepositories()
            }
        }
        
        func loadRepositories() async {
            guard !isLoading && !hasReachedEnd else { return }
            
            isLoading = true
            
            do {
                let newRepos = try await apiClient.fetchRepositories(query: "swift", page: currentPage, sortBy: sortBy)
                
                DispatchQueue.main.async {
                    let newEditableRepos = newRepos.map { EditableRepository(repository: $0) }
                    self.editableRepositories.append(contentsOf: newEditableRepos)
                    self.localStorage.save(repositories: newRepos)
                    self.currentPage += 1
                    
                    // Если получили меньше элементов, чем ожидалось, значит достигли конца
                    if newRepos.count < self.itemsPerPage {
                        self.hasReachedEnd = true
                    }
                    
                    // Сортировка репозиториев
                    self.editableRepositories.sort { $0.isEdited && !$1.isEdited }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = IdentifiableError(message: "Failed to fetch repositories: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    

    
    func deleteRepositories(at offsets: IndexSet) {
        let idsToDelete = offsets.map { editableRepositories[$0].repository.id }
        localStorage.delete(ids: idsToDelete)
        editableRepositories.remove(atOffsets: offsets)
    }
    
    func editRepository(_ editableRepository: EditableRepository) {
        if let index = editableRepositories.firstIndex(where: { $0.repository.id == editableRepository.repository.id }) {
            editableRepositories[index].repository = editableRepository.repository
            editableRepositories[index].isEdited = true
            localStorage.update(repository: editableRepository.repository)
            

            editableRepositories.sort { $0.isEdited && !$1.isEdited }
        }
    }
}
