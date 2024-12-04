import XCTest
@testable import VK_TEST_NEW

final class UnitTest: XCTestCase {
    
    var viewModel: RepositoryViewModel!
    var mockAPIClient: MockAPIClient!
    var mockLocalStorage: MockLocalStorage!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockLocalStorage = MockLocalStorage()
        viewModel = RepositoryViewModel(apiClient: mockAPIClient, localStorage: mockLocalStorage)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        mockLocalStorage = nil
        super.tearDown()
    }
    
    func testFetchRepositoriesSuccess() async {
        
        let expectedRepositories = [
            Repository(id: 1, name: "Repo1", description: "Description1", owner: Owner(avatar_url: "url1"), stargazers_count: 100),
            Repository(id: 2, name: "Repo2", description: "Description2", owner: Owner(avatar_url: "url2"), stargazers_count: 200)
        ]
        mockAPIClient.repositoriesToReturn = expectedRepositories
        
        
        await viewModel.loadRepositories()
        
        
        XCTAssertEqual(viewModel.editableRepositories.count, expectedRepositories.count)
        XCTAssertEqual(viewModel.editableRepositories[0].repository.name, "Repo1")
        XCTAssertEqual(viewModel.editableRepositories[1].repository.name, "Repo2")
    }
    
    func testFetchRepositoriesFailure() async {
        
        mockAPIClient.errorToThrow = URLError(.notConnectedToInternet)
        
        
        await viewModel.loadRepositories()
        
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage?.message, "Failed to fetch repositories: The Internet connection appears to be offline.")
    }
    
    func testSaveRepositoriesToLocalStorage() async {
        // Arrange
        let repository = Repository(id: 1, name: "Repo1", description: "Description1", owner: Owner(avatar_url: "url1"), stargazers_count: 100)
        mockAPIClient.repositoriesToReturn = [repository]
        
        // Act
        await viewModel.loadRepositories()
        
        // Assert
        XCTAssertEqual(mockLocalStorage.savedRepositories.count, 1)
        XCTAssertEqual(mockLocalStorage.savedRepositories[0].name, "Repo1")
    }
    
}
