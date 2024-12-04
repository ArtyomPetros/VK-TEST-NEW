import Foundation
import Combine
import SwiftUI
import RealmSwift

struct EditRepositoryView: View {
    @Binding var editableRepository: EditableRepository
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: RepositoryViewModel

    var body: some View {
        Form {
            Section(header: Text("Repository Details")) {
                TextField("Name", text: $editableRepository.repository.name)
                TextField("Description", text: Binding($editableRepository.repository.description, defaultValue: ""))

            }
        }
        .navigationTitle("Edit Repository")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.editRepository(editableRepository)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

extension Binding {
    init(_ source: Binding<Value?>, defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}

struct RepositoryView: View {
    @StateObject private var viewModel = RepositoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Sort by", selection: $viewModel.sortBy) {
                    Text("All").tag("all")
                    Text("Edited").tag("edited")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    ForEach(Array(viewModel.getFilteredRepositories().enumerated()), id: \.element.id) { index, repository in
                        let binding = Binding(
                            get: { repository },
                            set: { newValue in
                                viewModel.updateRepository(at: index, with: newValue)
                            }
                        )
                        
                        NavigationLink(destination: EditRepositoryView(editableRepository: binding).environmentObject(viewModel)) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    AsyncImage(url: URL(string: viewModel.filteredRepositories[index].repository.owner.avatar_url))
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    Text(viewModel.filteredRepositories[index].repository.name)
                                        .font(.headline)
                                }
                                if let description = viewModel.filteredRepositories[index].repository.description {
                                    Text(description)
                                        .font(.subheadline)
                                        .lineLimit(nil)
                                } else {
                                    Text("No description available")
                                        .font(.subheadline)
                                        .italic()
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteRepositories)
                }
                .onAppear {
                    Task {
                        await viewModel.loadRepositories()
                    }
                }
                .alert(item: $viewModel.errorMessage) { error in
                    Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Repositories")
        }
    }
}


struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}
