#import "AccountViewController.h"
#import "CategoryViewController.h"
#import "NotesViewController.h"
#import "NSString+NSStringUtils.h"

@interface AccountViewController () <UITextFieldDelegate, CategoryViewControllerDelegate, NotesViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (strong, nonatomic) IBOutlet UITextField *serviceField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end


@implementation AccountViewController

@synthesize delegate = _delegate;

@synthesize saveButton = _saveButton;
@synthesize serviceField = _serviceField;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

@synthesize account = _account;

- (Account *)account
{
  if (!_account) {
    _account = [Account new];
  }
  return _account;
}


#pragma mark UI/model sync

- (void)syncToUI
{
  self.serviceField.text  = self.account.service;
  self.usernameField.text = self.account.username;
  self.passwordField.text = self.account.password;
  
  [self categorySelected:self.account.category];
  [self notesUpdated:self.account.notes];
}

- (void)syncToModel
{
  self.account.service  = self.serviceField.text;
  self.account.username = self.usernameField.text;
  self.account.password = self.passwordField.text;
  
  self.account.category = [self categoryCell].detailTextLabel.text;
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


#pragma mark CategoryViewControllerDelegate

- (UITableViewCell *)categoryCell
{
  return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}

- (void)categorySelected:(NSString *)category
{
  self.account.category = category;
  
  [self categoryCell].detailTextLabel.text = category;
  
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]]
                        withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark NotesViewControllerDelegate

- (UITableViewCell *)notesCell
{
  return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
}

- (void)notesUpdated:(NSString *)notes
{
  self.account.notes = notes;
  
  [self notesCell].detailTextLabel.text = notes;
  
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]]
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
  
  self.saveButton.enabled = canSave;
  
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
  
  if ([segue.identifier isEqualToString:@"Category"]) {
    CategoryViewController *categoryVC = (CategoryViewController *) segue.destinationViewController;
    [categoryVC setDelegate:self];
    [categoryVC setCategory:self.account.category];
  }
  else if ([segue.identifier isEqualToString:@"Notes"]) {
    NotesViewController *notesVC = (NotesViewController *) segue.destinationViewController;
    [notesVC setDelegate:self];
    [notesVC setNotes:self.account.notes];
  }
}


#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
  [self syncToUI];
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [self syncToModel];
  [super viewDidDisappear:animated];
}

//- (void)setViewBackground
//{
//  UIImage *background = [UIImage imageNamed:@"light_gray_noise_background.png"];
//  self.view.backgroundColor = [UIColor colorWithPatternImage:background];
//  self.view.opaque = NO;
//}

- (void)enableOrDisableSaveButton
{
  self.saveButton.enabled = (self.account.uuid != nil);
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  //[self setViewBackground];
  [self enableOrDisableSaveButton];
}

- (void)viewDidUnload
{
  self.saveButton = nil;
  self.serviceField = nil;
  self.usernameField = nil;
  self.passwordField = nil;
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  else
    return YES;
}

@end
