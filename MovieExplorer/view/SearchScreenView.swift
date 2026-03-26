//
//  SearchScreenView.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 26/02/2026.
//

import SwiftUI

struct SearchScreenView: View {
    @StateObject private var vm = HomeScreenViewModel()
    @State private var query:String = ""
    // Data source (normally this could come from API/database)
    
    
    // What we show after filtering
    @State private var filteredItems: [MovieDetails?]? = []
    
    // Used to debounce user typing
    @State private var debounceTask: Task<Void, Never>?
    
    @State private var clickedMovie:MovieCardParams? =  nil

    func onMovieClicked(movieParams:MovieCardParams) {
        self.clickedMovie = movieParams
    }
    var body: some View {
        
        VStack(alignment: .leading){
            Text("search").font(.titleLarge)
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search Movies", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .submitLabel(.search)
                    .onSubmit {
                        // Immediate search when keyboard Search is tapped
                        Task {
                            filteredItems = await filterItems(with: query)
                        }
                    }
                
                if !query.isEmpty {
                    Button("Clear") {
                        query = ""
                        filteredItems = nil
                    }
                    .font(.caption)
                }
                
                
            }.frame(height: 36).padding(4)
                .background(.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if filteredItems?.isEmpty == true {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try another keyword.")
                )
            }
            
            ShowSearchResults()
        }.frame(maxWidth:.infinity,
                maxHeight: .infinity,
                alignment: .topLeading)
        .padding()
        .onAppear {
            // Initial state: show all
        }
        .onChange(of: query) { _, newValue in
            // Debounce: wait briefly after user stops typing
            debounceTask?.cancel()
            debounceTask = Task {
                guard !Task.isCancelled else { return }
                filteredItems = await filterItems(with: newValue)
            }
        }
        .navigationDestination(item:$clickedMovie) { movie in
            return MovieDetailsView(movieDetails: movie).environmentObject(vm)
        }
    }
    
    @ViewBuilder private func ShowSearchResults() -> some View {
        let items = filteredItems ?? []
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]


        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns,spacing: 3) {
                ForEach(items.indices, id: \.self) { index in
                    let movie = items[index]                    
                    MovieCardView(
                        movieCardParams: MovieCardParams.create(
                            id:movie?.id ?? 0,
                            title: movie?.title ?? "",
                            imageURL: (movie?.posterUrl?.absoluteString)
                            ?? "",
                            width: 100,
                            height: 150,
                            cornerRadius: 12,
                            onClick: onMovieClicked
                        )
                    )
                }
            }
        }
    }
    private func filterItems(with text: String)async -> [MovieDetails?]? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let movies = await vm.searchForMovie(query: trimmed)
        return movies
        
    }
}

#Preview {
    SearchScreenView()
}
