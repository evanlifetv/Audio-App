/*!
 *  SDTStateSaver.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/9/13
 */

#ifndef SDTStateSaver_h
#define SDTStateSaver_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SDTStateSaverLastTab) {
    SDTStateSaverLastTabUnknown        = -1,
    SDTStateSaverLastTabSweepGenerator = 0,
    SDTStateSaverLastTabToneGenerator  = 1,
    SDTStateSaverLastTabPinkNoise      = 2,
    SDTStateSaverLastTabMyMusic        = 3,
};

/*!
 *  <#Description#>
 */
@interface SDTStateSaver : NSObject

/*!
 *  Shared instance class method for accessing the shared instance of SDTStateSaver
 *
 *  \return Returns the shared instance of SDTStateSaver
 */
+ (instancetype)sharedState;


@property (nonatomic, assign) SDTStateSaverLastTab lastTab;

@end

#endif
