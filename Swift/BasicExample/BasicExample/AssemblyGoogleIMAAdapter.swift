//
//  AssemblyGoogleIMAAdapter.swift
//  BasicExample
//
//  Created by Wilmer Barrios on 30/06/23.
//  Copyright © 2023 Google, Inc. All rights reserved.
//

import GoogleInteractiveMediaAds
import UIKit

public protocol AssemblyVideoAdProvider {
    init(
        avPlayer: AVPlayer,
        videoView: UIView,
        viewController: UIViewController
    )
    
    func requestAds(adTagUrl: String)
}

public final class AssemblyGoogleIMAAdapter: NSObject, AssemblyVideoAdProvider { // Required for Google IMA Delegates
    private let contentPlayhead: IMAAVPlayerContentPlayhead
    private let adsLoader: IMAAdsLoader
    private let adDisplayContainer: () -> IMAAdDisplayContainer
    private var adsManager: IMAAdsManager? // This is fetched throug loader delegate
    private let viewController: UIViewController
    private let contentPlayer: AVPlayer
    
    public init(
        avPlayer: AVPlayer,
        videoView: UIView,
        viewController: UIViewController
    ) {
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: avPlayer)
        adsLoader = IMAAdsLoader(settings: nil)
        adDisplayContainer = { [weak videoView, weak viewController] in
            IMAAdDisplayContainer(adContainer: videoView!, viewController: viewController)
        }
        self.viewController = viewController
        self.contentPlayer = avPlayer
        super.init()
        self.start()
    }
    
    private func start() {
        adsLoader.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Self.contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: contentPlayer.currentItem)
    }
    
    @objc private func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (notification.object as! AVPlayerItem) == contentPlayer.currentItem {
            adsLoader.contentComplete()
        }
    }
    
    public func requestAds(adTagUrl: String) {
        // Create ad display container for ad rendering.
        let adDisplayContainer = adDisplayContainer()
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
          adTagUrl: adTagUrl,
          adDisplayContainer: adDisplayContainer,
          contentPlayhead: contentPlayhead,
          userContext: nil)

        adsLoader.requestAds(with: request)
    }
}

extension AssemblyGoogleIMAAdapter: IMAAdsLoaderDelegate {
    public func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        
        // Create ads rendering settings and tell the SDK to use the in-app browser.
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.linkOpenerPresentingController = viewController
        
        // Initialize the ads manager.
        adsManager?.initialize(with: adsRenderingSettings)
    }
    
    public func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        print("Error loading ads: \(adErrorData.adError.message ?? "nil")")
        contentPlayer.play()
    }
}

extension AssemblyGoogleIMAAdapter: IMAAdsManagerDelegate {
    public func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        if event.type == IMAAdEventType.LOADED {
            // When the SDK notifies us that ads have been loaded, play them.
            adsManager.start()
        }
    }
    
    public func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        // Something went wrong with the ads manager after ads were loaded. Log the error and play the
        // content.
        print("AdsManager error: \(error.message ?? "nil")")
        contentPlayer.play()
    }
    
    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        // The SDK is going to play ads, so pause the content.
        contentPlayer.pause()
    }
    
    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        // The SDK is done playing ads (at least for now), so resume the content.
        contentPlayer.play()
    }
}
