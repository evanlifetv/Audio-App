//
//  NSString+Additions.m
//  SoundTweak
//
//  Created by Bryan Montz on 11/14/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import "NSString+Additions.h"


@implementation NSString(Additions)

+ (NSString*)stringForFrequency:(double)frequency
{
	if (frequency >= 1000)
		return [NSString stringWithFormat:@"%.3f kHz", frequency / 1000.0];
	else
		return [NSString stringWithFormat:@"%.0f Hz", frequency];
}

@end
