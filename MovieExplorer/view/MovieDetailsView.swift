import SwiftUI
import YouTubePlayerKit

struct MovieDetailsView: View {
    @EnvironmentObject var vm: HomeScreenViewModel
    var movieDetails: MovieCardParams
    
    @State private var youtubeVideoId: String?
    @State var player = YouTubePlayer()
    @State var movieIsFavorite = false
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment:.center) {
                    Text("Trailer").font(.title)
                    Spacer()
                    Image(
                        systemName: movieIsFavorite ? "heart.fill" : "heart"
                    )
                    .onTapGesture {
                        vm.toggleFavorite(
                            MovieCardParams
                                .toMovieDetails(
                                    movieCardParams: movieDetails
                                )
                        )
                        movieIsFavorite = !movieIsFavorite
                    }
                }
                
                if youtubeVideoId != nil {
                    YouTubePlayerView(player)
                        .frame(height: 220) // fixed height, not maxHeight
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text(movieDetails.title).font(.title3)
                } else {
                    ProgressView("Loading Trailer Details!")
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .task(id: movieDetails.id) {
            youtubeVideoId = await vm.loadYoutubeKeyIdForVideo(id: movieDetails.id)
            if let key = youtubeVideoId, !key.isEmpty {
                try? await player.load(source: .video(id: key))
            }
        }
        .onAppear() {
            movieIsFavorite = vm.isFavorite(id: movieDetails.id)
        }
    }
}

