/*!
 *  SDTAudioManager.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#ifndef SDTAudioManager_h
#define SDTAudioManager_h

@import Foundation;
@import MediaPlayer;
@import AVFoundation;

#import "AudioFile.h"

/*!
 *  <#Description#>
 */
@interface SDTAudioManager : NSObject

/*!
 *  Shared instance class method for accessing the shared instance of SDTAudioManager
 *
 *  \return Returns the shared instance of SDTAudioManager
 */
+ (instancetype)sharedManager;

@property (nonatomic, strong, readonly) NSString *mediaDirectory;
@property (nonatomic, strong, readonly) NSString *artworkDirectory;

- (void)saveMediaItem:(MPMediaItem *)mediaItem;
- (void)saveMediaItem:(MPMediaItem *)mediaItem completion:(void(^)(NSError *error))completion;

- (void)willDeleteAudioFile:(AudioFile *)audioFile;

- (UIImage *)imageForAudioFile:(AudioFile *)audioFile;
- (void)asyncronousImageForAudioFile:(AudioFile *)audioFile completion:(void(^)(UIImage *image, NSNumber *audioFilePersistentID))completion;
- (NSURL *)audioURLForAudioFile:(AudioFile *)audioFile;

- (void)dumpMemCache;

@end

#endif
