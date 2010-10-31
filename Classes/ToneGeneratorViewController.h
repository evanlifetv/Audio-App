//
//  ToneGeneratorViewController.h
//  referenceaudio
//
//  Created by Bryan Montz on 10/30/10.
//  Copyright 2010 Evan Hamilton. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ToneGeneratorViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	UIPickerView *_pickerView;
}

@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;

@end
