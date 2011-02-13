
#import "SupportViewController.h"
#import "ShareController.h"
#import "TBCController.h"
#import "AudioControlsViewController.h"

#define WEB_SUPPORT_URL_STRING @"http://soundtweakapp.com/"
#define EMAIL_SUPPORT_ADDRESS @"evan@evanhamilton.tv"
#define EMAIL_SUPPORT_SUBJECT @"Question About SoundTweak"
#define BUG_REPORT_ADDRESS @"evan@evanhamilton.tv"
#define BUG_REPORT_SUBJECT @"Bug Report"
#define BUG_REPORT_BODY @"What I expected:\n\n\nWhat I saw:\n\n\nSteps to repeat:"
#define FEATURE_REQUEST_ADDRESS @"evan@evanhamilton.tv"
#define FEATURE_REQUEST_SUBJECT @"Feature Request"

@implementation SupportViewController

@synthesize webButton = _webButton;
@synthesize emailButton = _emailButton;
@synthesize bugButton = _bugButton;
@synthesize featureButton = _featureButton;

#pragma mark -
#pragma mark Initializer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.tabBarItem.image = [UIImage imageNamed:@"support.png"];
        self.tabBarItem.title = @"Support";
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[TBCController sharedTBCController] setToFullSize];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    [AudioControlsViewController sharedInstance].currentType = kSTTabTypeSupport;
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	//set the tab bar controller's view to the bottom half of the screen
	[[TBCController sharedTBCController] setToHalfSize];
}


#pragma mark -
#pragma mark Memory management

- (void) viewDidUnload
{
    [super viewDidUnload];
	
    self.webButton = nil;
    self.emailButton = nil;
    self.bugButton = nil;
    self.featureButton = nil;
}


- (void)dealloc
{
    [_webButton release];
    [_emailButton release];
    [_bugButton release];
    [_featureButton release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark Actions

- (IBAction)buttonPressed:(id)sender
{
	if (sender == _webButton) {
		NSURL *url = [NSURL URLWithString: WEB_SUPPORT_URL_STRING];
		[[UIApplication sharedApplication] openURL:url];
		
	} else if (sender == _emailButton) {
		if ([ShareController canSendEmail]) {
			[[ShareController sharedInstance] sendEmailToAddress:EMAIL_SUPPORT_ADDRESS
													 WithSubject:EMAIL_SUPPORT_SUBJECT
															body:nil];
		}
		
	} else if (sender == _bugButton) {
		if ([ShareController canSendEmail]) {
			[[ShareController sharedInstance] sendEmailToAddress:BUG_REPORT_ADDRESS
													 WithSubject:BUG_REPORT_SUBJECT
															body:BUG_REPORT_BODY];
		}
		
	} else if (sender == _featureButton) {
		if ([ShareController canSendEmail]) {
			[[ShareController sharedInstance] sendEmailToAddress:FEATURE_REQUEST_ADDRESS
													 WithSubject:FEATURE_REQUEST_SUBJECT
															body:nil];
		}
	}
}


@end
