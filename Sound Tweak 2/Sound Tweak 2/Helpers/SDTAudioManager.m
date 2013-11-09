/*!
 * SDTAudioManager.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */


#import "SDTAudioManager.h"
#import "NSFileManager+SDTFileManager.h"

id static _sharedSDTAudioManager = nil;

@interface SDTAudioManager ()

@property (nonatomic, strong) NSCache *imageFileCache;

@end

@implementation SDTAudioManager
@synthesize mediaDirectory = _mediaDirectory;
@synthesize artworkDirectory = _artworkDirectory;

#pragma mark -
#pragma mark - Initialization
- (id)init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)didReceiveMemoryWarning:(NSNotification *)notif {
    [self dumpMemCache];
}
- (void)dumpMemCache {
    [self.imageFileCache removeAllObjects];
}

#pragma mark -
#pragma mark - Lazy Loaders
- (NSCache *)imageFileCache {
    @synchronized (self) {
        if (!_imageFileCache) {
            _imageFileCache = [[NSCache alloc] init];
            _imageFileCache.countLimit = 100;
        }
        return _imageFileCache;
    }
}

#pragma mark -
#pragma mark - Singleton
+ (instancetype)sharedManager {
	@synchronized (self) {
        if (!_sharedSDTAudioManager) {
            _sharedSDTAudioManager = [[[self class] alloc] init];
        }
        return _sharedSDTAudioManager;
    }
}

#pragma mark -
#pragma mark - Helpers
- (NSString *)mediaDirectory {
    if (!_mediaDirectory) {
        _mediaDirectory = [[[NSFileManager defaultManager] cacheDirectory] stringByAppendingPathComponent:@"audio_cache"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_mediaDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_mediaDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _mediaDirectory;
}
- (NSString *)artworkDirectory {
    if (!_artworkDirectory) {
        _artworkDirectory = [[[NSFileManager defaultManager] cacheDirectory] stringByAppendingPathComponent:@"artwork_cache"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_artworkDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_artworkDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _artworkDirectory;
}
- (void)saveMediaItem:(MPMediaItem *)mediaItem {
    [self saveMediaItem:mediaItem completion:nil];
}
- (void)saveMediaItem:(MPMediaItem *)mediaItem completion:(void(^)(NSError *error))completion {
    NSURL *itemURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    NSMutableDictionary *info = [@{
                                   MPMediaItemPropertyPersistentID:     ([mediaItem valueForProperty:MPMediaItemPropertyPersistentID])     ?: [NSNull null],
                                   MPMediaItemPropertyTitle:            ([mediaItem valueForProperty:MPMediaItemPropertyTitle])            ?: [NSNull null],
                                   MPMediaItemPropertyArtist:           ([mediaItem valueForProperty:MPMediaItemPropertyArtist])           ?: [NSNull null],
                                   MPMediaItemPropertyPlaybackDuration: ([mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration]) ?: [NSNull null],
                                   MPMediaItemPropertyAlbumTitle:       ([mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle])       ?: [NSNull null],
                                   } mutableCopy];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.m4a",info[MPMediaItemPropertyPersistentID]];
    info[@"assetName"] = fileName;
    
    
    @autoreleasepool {
        MPMediaItemArtwork *artwork = [mediaItem valueForProperty:MPMediaItemPropertyArtwork];
        if (artwork) {
            NSString *imageName = [NSString stringWithFormat:@"%@.png",info[MPMediaItemPropertyPersistentID]];
            NSString *imagePath = [self.artworkDirectory stringByAppendingPathComponent:imageName];
            UIImage *artworkImage = [artwork imageWithSize:CGSizeMake(300, 300)];
            NSData *imageData = UIImagePNGRepresentation(artworkImage);
            [imageData writeToFile:imagePath atomically:YES];
            info[@"artworkName"] = imageName;
            [self.imageFileCache setObject:artworkImage forKey:imageName];
        }
    }
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:itemURL options:nil];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songAsset presetName:AVAssetExportPresetAppleM4A];
    exporter.outputFileType =   @"com.apple.m4a-audio";
    
    NSString *exportPath = [self.mediaDirectory stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    exporter.outputURL = [NSURL fileURLWithPath:exportPath];
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        switch (exporter.status) {
            case AVAssetExportSessionStatusFailed:
                if (completion) {
                    completion(exporter.error);
                }
                break;
            case AVAssetExportSessionStatusCompleted:
                [self writeAudioFileForInfo:info];
                if (completion) {
                    completion(nil);
                }
                break;
            default:
                break;
        }
    }];
}

- (void)writeAudioFileForInfo:(NSDictionary *)info {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.parentContext = [[OSDCoreDataManager sharedManager] managedObjectContext];
    
    AudioFile *file = [AudioFile insertIntoContext:context];
    [file setValuesForKeysWithDictionary:info];
    
    if ([context save:nil]) {
        [[OSDCoreDataManager sharedManager] save];
    }
}

- (void)willDeleteAudioFile:(AudioFile *)audioFile {
    NSString *filePath = [self.mediaDirectory stringByAppendingPathComponent:audioFile.assetName];
    NSString *imagePath = [self.artworkDirectory stringByAppendingPathComponent:audioFile.artworkName];
    NSError *fileError = nil;
    NSError *imageError = nil;
    
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&fileError]) {
        NSLog(@"File Error: %@",fileError);
    }
    if (![[NSFileManager defaultManager] removeItemAtPath:imagePath error:&imageError]) {
        NSLog(@"Image Error: %@",imageError);
    }
}


- (UIImage *)imageForAudioFile:(AudioFile *)audioFile {
    UIImage *image = [self.imageFileCache objectForKey:audioFile.artworkName];
    if (image) {
        return image;
    }
    image = [UIImage imageWithContentsOfFile:[self.artworkDirectory stringByAppendingPathComponent:audioFile.artworkName]];
    [self.imageFileCache setObject:image forKey:audioFile.artworkName];
    return image;
}
- (NSURL *)audioURLForAudioFile:(AudioFile *)audioFile {
    return [NSURL fileURLWithPath:[self.mediaDirectory stringByAppendingPathComponent:audioFile.assetName]];
}

@end
