//
//  AudioFile.h
//  Sound Tweak 2
//
//  Created by Skylar Schipper on 11/8/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "OSDAudioPlayer.h"

@interface AudioFile : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * persistentID;
@property (nonatomic, retain) NSString * albumTitle;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * artworkName;
@property (nonatomic, retain) NSString * assetName;
@property (nonatomic, retain) NSNumber * playbackDuration;

- (BOOL)isPlayerItem:(OSDAudioPlayerItem *)playerItem;

@end
