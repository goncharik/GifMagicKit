//
//  GifMagic.swift
//  GifMagicKit
//
//  Created by Eugene on 3/21/16.
//  Copyright © 2016 FocusedGenius. All rights reserved.
//

import Foundation
import CoreGraphics
import ImageIO
import AVFoundation

#if os(iOS)
    import MobileCoreServices
    import UIKit
#else
    import CoreServices
    import WebKit
#endif

public func GifMagic(videoURL videoURL:NSURL, loopCount: Int, completion: (NSURL) -> ()) {
    
    let asset: AVURLAsset = AVURLAsset(URL: videoURL)
    
    var videoWidth, videoHeight: CGFloat
    if let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo).first {
        videoWidth = assetTrack.naturalSize.width
        videoHeight = assetTrack.naturalSize.height
    }
    else {
        videoWidth = 0.0
        videoHeight = 0.0
    }
    
    var optimalSize = GifSize.medium
    
    if videoWidth >= 1200 || videoHeight >= 1200 {
        optimalSize = .veryLow
    }
    else if videoWidth >= 800 || videoHeight >= 800 {
        optimalSize = .low
    }
    else if videoWidth >= 400 || videoHeight >= 400 {
        optimalSize = .medium
    }
    else if videoWidth < 400 || videoHeight < 400 {
        optimalSize = .high
    }
    
    let videoLength = Double(asset.duration.timescale / asset.duration.timescale)
    let framesPerSecond = 4.0;
    let frameCount = videoLength * framesPerSecond;
    
    GifMagic(videoURL: videoURL, frameCount: Int(frameCount), delayTime: 0.2, loopCount: loopCount, gifSize: optimalSize, completion: completion)
}

public func GifMagic(videoURL videoURL:NSURL, frameCount: Int, delayTime: Double, loopCount: Int, completion: (NSURL) -> ()) {
    GifMagic(videoURL: videoURL, frameCount: frameCount, delayTime: delayTime, loopCount: loopCount, gifSize: .medium, completion: completion)
}

func GifMagic(videoURL videoURL:NSURL, frameCount: Int, delayTime: Double, loopCount: Int, gifSize: GifSize, completion: (NSURL) -> ()) {
    let fileProperties = generateFileProperties(loopCount: loopCount)
    let frameProperties = generateFrameProperties(delayTime: delayTime)
    
    let asset: AVURLAsset = AVURLAsset(URL: videoURL)
    
    // Get the length of the video in seconds
    let videoLength = Double(asset.duration.timescale / asset.duration.timescale)
    
    // How far along the video track we want to move, in seconds.
    let increment = videoLength / Double(frameCount);
    
    let timeInterval: Int32 = 600
    
    // Add frames to the buffer
    var timePoints = [CMTime]();
    for currentFrame in 0...Int(frameCount) {
        let seconds = increment * Double(currentFrame)
        let time = CMTimeMakeWithSeconds(seconds, timeInterval)
        timePoints.append(time)
    }
    
    // Prepare group for firing completion block
    let gifQueue = dispatch_group_create()
    dispatch_group_enter(gifQueue)
    
    var gifURL: NSURL!
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        
        gifURL = createGif(timePoints: timePoints, url: videoURL, fileProperties: fileProperties, frameProperties: frameProperties, frameCount: Int(frameCount), gifSize: gifSize)
        
        dispatch_group_leave(gifQueue)
    }
    
    dispatch_group_notify(gifQueue, dispatch_get_main_queue()) {
        // Return GIF URL
        completion(gifURL)
    }
}

//MARK: - Helpers

func createGif(timePoints timePoints:[CMTime], url: NSURL, fileProperties: [String:String], frameProperties: [String:String], frameCount:Int, gifSize: GifSize) -> NSURL? {
    let fileName = "Gif.gif"
    let tolerance = 0.1
    let timeInterval: Int32 = 600
    let temporaryFile = NSTemporaryDirectory().stringByAppendingString(fileName)
    let fileURL = NSURL.fileURLWithPath(temporaryFile)
    
    guard let destination = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, frameCount, nil) else {
        return nil
    }
    
    let asset = AVURLAsset(URL: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    
    let toleranceTime = CMTimeMakeWithSeconds(tolerance, timeInterval)
    generator.requestedTimeToleranceBefore = toleranceTime
    generator.requestedTimeToleranceAfter = toleranceTime
    
    var previousImageRefCopy: CGImageRef? = nil
    for time in timePoints {
        var imageRef: CGImageRef? = nil
        
        #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
            imageRef = gifSize/10 != 1 ? createImageWithScale(generator.copyCGImageAtTime(time, actualTime: nil), gifSize/10) : generator.copyCGImageAtTime(time, actualTime: nil)
        #elseif TARGET_OS_MAC
            do {
                try imageRef = generator.copyCGImageAtTime(time, actualTime: nil)
            }
            catch let error as NSError {
                print("Error copying image: \(error)")
            }
        #endif
        
        if ((imageRef) != nil) {
            previousImageRefCopy = CGImageCreateCopy(imageRef)
        } else if ((previousImageRefCopy) != nil) {
            imageRef = CGImageCreateCopy(previousImageRefCopy)
        } else {
            print("Error copying image and no previous frames to duplicate")
            return nil
        }
        CGImageDestinationAddImage(destination, imageRef!, frameProperties)
    }
    
    CGImageDestinationSetProperties(destination, fileProperties)
    // Finalize the GIF
    if (!CGImageDestinationFinalize(destination)) {
        print("Failed to finalize GIF destination")
        return nil;
    }
    
    return fileURL;
}

enum GifSize: Int {
    case veryLow = 2, low = 3, medium = 5, high = 7, original = 10
}

func generateFileProperties(loopCount loopCount: Int) -> [String:String] {
    return [:];
}

func generateFrameProperties(delayTime delayTime: Double) -> [String:String] {
    return [:];
}
