#import "AccountViewController.h"
#import "NotesViewController.h"
#import "NSString+NSStringUtils.h"

@interface AccountViewController () <UITextFieldDelegate, NotesViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *serviceField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end


@implementation AccountViewController

@synthesize delegate = _delegate;

@synthesize serviceField = _serviceField;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

@synthesize account = _account;

#pragma mark UI/model sync

- (void)syncToUI
{
  self.serviceField.text  = self.account.service;
  self.usernameField.text = self.account.username;
  self.passwordField.text = self.account.password;
  [self notesUpdated:self.account.notes];
}

- (void)syncToModel
{
  self.account.service  = self.serviceField.text;
  self.account.username = self.usernameField.text;
  self.account.password = self.passwordField.text;
  self.account.notes    = [self notesCell].detailTextLabel.text;
}


#pragma mark Actions

- (void)dismissViewController
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveAccount:(id)sender
{
  [self syncToModel];
  [self.delegate accountSaved:self.account];
  [self dismissViewController];
}

- (IBAction)cancelAccount:(id)sender
{
  [self dismissViewController];
}


#pragma mark NotesViewControllerDelegate

- (UITableViewCell *)notesCell
{
  return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}

- (void)notesUpdated:(NSString *)notes
{
  self.account.notes = notes;
  
  [self notesCell].detailTextLabel.text = notes;
  
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]]
                        withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.serviceField)
    [self.usernameField becomeFirstResponder];
  
  else if (textField == self.usernameField)
    [self.passwordField becomeFirstResponder];
  
  else if (textField == self.passwordField)
    [self.passwordField resignFirstResponder];
  
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  BOOL canSave = (range.location > 0 || [string isNotEmpty]) &&
                 (textField == self.serviceField  || [self.serviceField.text isNotEmpty]) &&
                 (textField == self.usernameField || [self.usernameField.text isNotEmpty]) &&
                 (textField == self.passwordField || [self.passwordField.text isNotEmpty]);
  
  self.navigationItem.rightBarButtonItem.enabled = canSave;
  
  return YES;
}


#pragma mark UIScrollViewDelegate

- (void)resignTableViewFirstResponder
{
  [self.tableView endEditing:YES]; // allows touchesBegan:withEvent: method to be called
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  [self resignTableViewFirstResponder];
}


#pragma mark UIResponder

- (void)textField:(UITextField *)textField resignFirstResponderForView:(UIView *)view
{
  if ([textField isFirstResponder] && (textField != view))
    [textField resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UIView *touchView = ((UITouch *) [[event allTouches] anyObject]).view;
  
  [self textField:self.serviceField resignFirstResponderForView:touchView];
  [self textField:self.usernameField resignFirstResponderForView:touchView];
  [self textField:self.passwordField resignFirstResponderForView:touchView];
}


#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  [self resignTableViewFirstResponder];
  
  if ([segue.identifier isEqualToString:@"Notes"]) {
    NotesViewController *notesVC = segue.destinationViewController;
    [notesVC setDelegate:self];
    [notesVC setNotes:self.account.notes];
  }
}


#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
  [self syncToUI];
  [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [self syncToModel];
  [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationItem.rightBarButtonItem.enabled = (self.account.uuid != nil);
  self.navigationItem.title = self.account.service;
}

- (void)viewDidUnload
{
  self.serviceField = nil;
  self.usernameField = nil;
  self.passwordField = nil;
  [super viewDidUnload];
}


#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  else
    return YES;
}

@end
