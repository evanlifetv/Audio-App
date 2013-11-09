//
//  UIDevice+SDTDevice.m
//  Sound Tweak 2
//
//  Created by Skylar Schipper on 11/9/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import "UIDevice+SDTDevice.h"

static BOOL _isPad = NO;

@implementation UIDevice (SDTDevice)

- (BOOL)isPad {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _isPad = [self userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    });
    return _isPad;
}

@end
