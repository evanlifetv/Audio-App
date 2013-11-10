//
//  UIColor+SDTColor.h
//  Sound Tweak 2
//
//  Created by Skylar Schipper on 11/8/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_INLINE UIColor *_RGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    return [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a];
}
#define RGBA(r,g,b,a) _RGBA(r,g,b,a)
#define RGB(r,g,b) _RGBA(r,g,b,1.0)

@interface UIColor (SDTColor)

+ (UIColor *)soundTweakPurple;
+ (UIColor *)soundTweakLightPurple;
+ (UIColor *)soundTweakDarkPurple;
+ (UIColor *)soundTweakHairLinePurple;
+ (UIColor *)selectedSoundTweakPurple;

+ (UIColor *)deleteColorRed;

@end
