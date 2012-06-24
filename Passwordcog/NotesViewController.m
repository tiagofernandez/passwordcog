#import <QuartzCore/QuartzCore.h>

#import "NotesViewController.h"

@interface NotesViewController ()

@property (strong, nonatomic) IBOutlet UITextView *notesTextView;

@end


@implementation NotesViewController

@synthesize delegate = _delegate;
@synthesize notes = _notes;

@synthesize notesTextView = _notesTextView;


#pragma mark Actions

- (IBAction)doneNoting:(id)sender
{
  [self.delegate notesUpdated:self.notesTextView.text];
  [self.navigationController popViewControllerAnimated:YES];
}


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
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
      newFrame = CGRectMake(0, 0, 320, 200);
    
    else if (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown)
      newFrame = CGRectMake(0, 0, 480, 94);
  }
  self.notesTextView.frame = newFrame;
}


#pragma mark View lifecycle

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  [self adjustNotesTextViewToInterfaceOrientation:interfaceOrientation];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  else
    return YES;
}

@end
