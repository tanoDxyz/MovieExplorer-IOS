//
//  MovieCardView.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 30/01/2026.
//

import SwiftUI

struct MovieCardView: View {
    var movieCardParams:MovieCardParams
    var body: some View {
        VStack(alignment: .leading){
            KFRemoteImageView(url: movieCardParams.imageURL)
                .frame(
                    width: movieCardParams.width,
                    height: movieCardParams.height
                ).clipShape(
                    RoundedRectangle(
                        cornerRadius: movieCardParams.cornerRadius
                    )
                )
            Text(movieCardParams.title)
                .font(.caption)
                .lineLimit(2)
                .frame(width: movieCardParams.width, alignment: .center)
        }.frame(height: movieCardParams.height + 40,alignment: .top).onTapGesture {
            movieCardParams.onClick(movieCardParams)
        } 
    }
}

struct MovieCardParams:Hashable,Identifiable {
    var id:Int
    var title:String
    var imageURL:String
    var width:CGFloat
    var height:CGFloat
    var cornerRadius:CGFloat
    var onClick:(MovieCardParams)->Void
    static func create(
        id:Int = 0,
        title:String = "movie",
        imageURL:String = "https://picsum.photos/300",
        width:CGFloat = 64,
        height:CGFloat = 64,
        cornerRadius:CGFloat = 8,onClick:@escaping (MovieCardParams)->Void = {params in}) -> MovieCardParams {
        
            return MovieCardParams(
                id: id,
                title: title,
                imageURL:imageURL,
                width:width,
                height:height,
                cornerRadius:cornerRadius,
                onClick: onClick
            )
        }
    
    static func == (lhs: MovieCardParams, rhs: MovieCardParams) -> Bool {
        lhs.id == rhs.id
    }

    static func toMovieDetails(movieCardParams:MovieCardParams)->MovieDetails {
        return MovieDetails(
            posterUrl: URL(string: movieCardParams.imageURL),
            id:movieCardParams.id,
            title:movieCardParams.title,
            description: "",
            year: 0,
            score:0
        )
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#Preview {
    let obj  = MovieCardParams.create()
    MovieCardView(movieCardParams: obj)
}
