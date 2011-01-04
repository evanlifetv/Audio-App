
#import <Foundation/Foundation.h>


@interface SupportViewController : UIViewController {

	UIButton *_webButton;
	UIButton *_emailButton;
	UIButton *_bugButton;
	UIButton *_featureButton;
}

@property (nonatomic, retain) IBOutlet UIButton *webButton;
@property (nonatomic, retain) IBOutlet UIButton *emailButton;
@property (nonatomic, retain) IBOutlet UIButton *bugButton;
@property (nonatomic, retain) IBOutlet UIButton *featureButton;

- (IBAction)buttonPressed:(id)sender;

@end
