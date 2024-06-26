//
//  CompactMiniPlayerView.swift
//  Tuneful
//
//  Created by Martin Fekete on 21/01/2024.
//

import SwiftUI
import MediaPlayer

struct CompactMiniPlayerView: View {
    
    @EnvironmentObject var playerManager: PlayerManager
    @AppStorage("miniPlayerBackground") var miniPlayerBackground: BackgroundType = .albumArt
    @State private var isShowingPlaybackControls = false
    
    private var imageSize: CGFloat = 140.0
    private var cornerRadius: CGFloat = 10.0
    private var playbackButtonSize: CGFloat = 15.0
    private var playPauseButtonSize: CGFloat = 25.0
    private weak var parentWindow: MiniPlayerWindow!
    
    init(parentWindow: MiniPlayerWindow) {
        self.parentWindow = parentWindow
    }

    var body: some View {
        ZStack {
            if miniPlayerBackground == .albumArt && playerManager.isRunning {
                Image(nsImage: playerManager.track.albumArt)
                    .resizable()
                    .scaledToFill()
                VisualEffectView(material: .popover, blendingMode: .withinWindow)
            }
            
            if !playerManager.isRunning {
                Text("Please open \(playerManager.name) to use Tuneful")
                    .foregroundColor(.primary.opacity(0.4))
                    .font(.system(size: 14, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(15)
                    .padding(.bottom, 20)
            } else {
                Image(nsImage: playerManager.track.albumArt)
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(8)
                    .frame(width: self.imageSize, height: self.imageSize)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .dragWindowWithClick()
                    .gesture(
                        TapGesture(count: 2).onEnded {
                            self.playerManager.openMusicApp()
                        }
                    )

                HStack(spacing: 8) {
                    if playerManager.isLikeAuthorized() {
                        Button {
                            playerManager.toggleLoveTrack()
                        } label: {
                            Image(systemName: playerManager.isLoved ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        .pressButtonStyle()
                    }
                    
                    Button(action: playerManager.previousTrack){
                        Image(systemName: "backward.end.fill")
                            .resizable()
                            .frame(width: self.playbackButtonSize, height: self.playbackButtonSize)
                            .animation(.easeInOut(duration: 2.0), value: 1)
                    }
                    .pressButtonStyle()
                    
                    PlayPauseButton(buttonSize: self.playPauseButtonSize)
                    
                    Button(action: playerManager.nextTrack) {
                        Image(systemName: "forward.end.fill")
                            .resizable()
                            .frame(width: self.playbackButtonSize, height: self.playbackButtonSize)
                            .animation(.easeInOut(duration: 2.0), value: 1)
                    }
                    .pressButtonStyle()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
                .cornerRadius(cornerRadius)
                .opacity(isShowingPlaybackControls ? 1 : 0)
            }
        }
        .frame(width: 155, height: 155)
        .onHover { _ in
            withAnimation(.linear(duration: 0.1)) {
                self.isShowingPlaybackControls.toggle()
            }
        }
        .overlay(
            NotificationView()
        )
        .if(miniPlayerBackground == .transparent || !playerManager.isRunning) { view in
            view.background(VisualEffectView(material: .underWindowBackground, blendingMode: .withinWindow))
        }
    }
}
