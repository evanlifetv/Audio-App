//
//  UIColor+SDTColor.m
//  Sound Tweak 2
//
//  Created by Skylar Schipper on 11/8/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import "UIColor+SDTColor.h"

@implementation UIColor (SDTColor)

+ (UIColor *)soundTweakPurple {
    return _RGBA(146.0,69.0,255.0,1.0);
}
+ (UIColor *)soundTweakDarkPurple {
    return _RGBA(36.0,0.0,145.0,1.0);
}
+ (UIColor *)soundTweakLightPurple {
    return _RGBA(166.0, 89.0, 255.0, 1.0);
}
+ (UIColor *)soundTweakHairLinePurple {
    return _RGBA(196.0, 119.0, 255.0, 1.0);
}
+ (UIColor *)selectedSoundTweakPurple {
    return _RGBA(126.0, 49.0, 235.0, 1.0);
}

+ (UIColor *)deleteColorRed {
    return _RGBA(226,68,69,1.0);
}

@end
