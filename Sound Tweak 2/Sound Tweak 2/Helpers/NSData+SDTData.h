//
//  NSData+SDTData.h
//  Sound Tweak 2
//
//  Created by Skylar Schipper on 11/8/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@import MediaPlayer;
@import AVFoundation;

@interface NSData (SDTData)

+ (NSData *)dataWithMediaItem:(MPMediaItem *)item;

@end
