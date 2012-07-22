#import "AccountViewController.h"
#import "NotesViewController.h"
#import "NSString+NSStringUtils.h"

@interface AccountViewController () <UITextFieldDelegate, NotesViewControllerDelegate>

@property (nonatomic) BOOL syncedFromModel;

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end


@implementation AccountViewController

@synthesize delegate = _delegate;

@synthesize syncedFromModel = _syncedFromModel;

@synthesize category = _category;
@synthesize account = _account;

@synthesize nameField = _nameField;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

- (void)setAccount:(Account *)account
{
  _account = account;
}


#pragma mark Actions

- (void)dismissViewController
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveAccount:(id)sender
{
  Account *account = (self.account) ? self.account : [Account createEntity];
  
  account.name     = self.nameField.text;
  account.username = self.usernameField.text;
  account.password = self.passwordField.text; // TODO Encrypt password
  account.category = self.category;
  account.notes    = [self notesCell].detailTextLabel.text;
  account.index    = [Account totalOfAccountsInCategory:self.category];
  
  [[NSManagedObjectContext contextForCurrentThread] save];
  
  [self.delegate accountSaved:account];
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
  [self notesCell].detailTextLabel.text = notes;
  
  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]]
                        withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.nameField)
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
                 (textField == self.nameField  || [self.nameField.text isNotEmpty]) &&
                 (textField == self.usernameField || [self.usernameField.text isNotEmpty]) &&
                 (textField == self.passwordField || [self.passwordField.text isNotEmpty]);
  
  self.navigationItem.rightBarButtonItem.enabled = canSave;
  
  return YES;
}


#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return (section == 0) ? self.category : nil;
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
  
  [self textField:self.nameField resignFirstResponderForView:touchView];
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
    [notesVC setNotes:[self notesCell].detailTextLabel.text];
  }
}


#pragma mark View lifecycle

- (void)syncFromModel
{
  if (!self.syncedFromModel) {
    
    self.nameField.text     = self.account.name;
    self.usernameField.text = self.account.username;
    self.passwordField.text = self.account.password;
    
    [self notesCell].detailTextLabel.text = self.account.notes;
    
    self.syncedFromModel = YES;
  }
}

- (void)enableOrDisableSaveButton
{
  self.navigationItem.rightBarButtonItem.enabled = (self.account != nil);
}

- (void)setNavigationBarTitle
{
  self.navigationItem.title = [self.account.name isNotEmpty] ? self.account.name : @"New Account";
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self syncFromModel];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setNavigationBarTitle];
  [self enableOrDisableSaveButton];
}

- (void)viewDidUnload
{
  self.nameField = nil;
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
