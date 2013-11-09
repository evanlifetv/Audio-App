/*!
 * SDTStateSaver.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/9/13
 */


#import "SDTStateSaver.h"

id static _sharedSDTStateSaver = nil;

@implementation SDTStateSaver


#pragma mark -
#pragma mark - Initialization
- (id)init {
	self = [super init];
	if (self) {
		
	}
	return self;
}

#pragma mark -
#pragma mark - Singleton

+ (instancetype)sharedState {
	@synchronized (self) {
        if (!_sharedSDTStateSaver) {
            _sharedSDTStateSaver = [[[self class] alloc] init];
        }
        return _sharedSDTStateSaver;
    }
}

- (void)setLastTab:(SDTStateSaverLastTab)lastTab {
    [[NSUserDefaults standardUserDefaults] setInteger:lastTab forKey:@"last_tab"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (SDTStateSaverLastTab)lastTab {
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_tab"];
    if (!obj) {
        return SDTStateSaverLastTabUnknown;
    }
    return [obj integerValue];
}

@end
