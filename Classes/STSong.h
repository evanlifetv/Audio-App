//
//  STSong.h
//  SoundTweak
//
//  Created by Bryan Montz on 2/23/11.
//  Copyright 2011 Evan Hamilton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaPlayer/MPMediaQuery.h"

@interface STSong : NSObject {
    NSString            *_artist;
    NSString            *_title;
    NSTimeInterval      _duration;
    MPMediaItemArtwork  *_artwork;
    MPMediaItem         *_sourceMediaItem;
}

@property (nonatomic, readonly) NSString *artist;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) MPMediaItem *sourceMediaItem;

+(STSong *) songWithMediaItem: (MPMediaItem *) item;
-(UIImage *) artworkImageWithSize: (CGSize) size;

@end
