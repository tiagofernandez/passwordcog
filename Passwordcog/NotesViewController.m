#import <QuartzCore/QuartzCore.h>

#import "NotesViewController.h"

@interface NotesViewController ()

@property (strong, nonatomic) IBOutlet UITextView *notesTextView;

@end


@implementation NotesViewController

@synthesize delegate = _delegate;
@synthesize notes = _notes;

@synthesize notesTextView = _notesTextView;


#pragma mark Text view

- (void)initNotesTextView
{
  self.notesTextView.text = self.notes;
  self.notesTextView.layer.cornerRadius = 10;
  self.notesTextView.clipsToBounds = YES;
  [self.notesTextView becomeFirstResponder];
}

- (void)adjustNotesTextViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  CGRect newFrame = self.notesTextView.frame;
  
  if (interfaceOrientation == UIInterfaceOrientationPortrait) {
    newFrame = CGRectMake(0, 0, 320, IS_IPHONE_4_INCHES ? 286 : 200);
  }
  else if (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) {
    newFrame = CGRectMake(0, 0, IS_IPHONE_4_INCHES ? 656 : 480, 94);
  }
  self.notesTextView.frame = newFrame;
}


#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self adjustNotesTextViewToInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self.delegate notesUpdated:self.notesTextView.text];
  [self.navigationController popViewControllerAnimated:YES];
  [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self initNotesTextView];
}

- (void)viewDidUnload
{
  self.notesTextView = nil;
  [super viewDidUnload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self adjustNotesTextViewToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([PasswordcogAppDelegate userInterfaceIdiomPad])
    return YES;
  else
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
