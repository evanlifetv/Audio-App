//
//  NSFileManager+SDTFileManager.m
//  Sound Tweak 2
//
//  Created by Skylar Schipper on 11/8/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import "NSFileManager+SDTFileManager.h"

@implementation NSFileManager (SDTFileManager)


- (NSString *)documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}
- (NSString *)cacheDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

@end
