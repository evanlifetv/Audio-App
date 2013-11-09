/*!
 *  SDTViewController.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 11/8/13
 */

#import "SDTViewController.h"

@implementation SDTViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
