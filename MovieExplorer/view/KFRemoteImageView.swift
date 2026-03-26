//
//  KFRemoteImageView.swift
//  MovieExplorer
//
//  Created by syed tanveer hussain on 03/02/2026.
//

import SwiftUI
import Kingfisher
internal import System

struct KFRemoteImageView: View {
    let url: String

    var body: some View {
        KFImage.url(URL(string: url))
            .placeholder {
                ProgressView()
            }
            .cancelOnDisappear(true)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}


#Preview {
    KFRemoteImageView(url:("https://picsum.photos/300"))
}
