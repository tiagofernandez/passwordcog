#import "AccountViewController.h"
#import "NotesViewController.h"

@interface AccountViewController () <UITextFieldDelegate, NotesViewControllerDelegate>

@property (nonatomic) BOOL syncedFromModel;

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextView *notesField;

@end


@implementation AccountViewController

@synthesize delegate = _delegate;

@synthesize syncedFromModel = _syncedFromModel;

@synthesize categoryName = _categoryName;
@synthesize account = _account;

@synthesize nameField = _nameField;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize notesField = _notesField;

- (void)setAccount:(Account *)account
{
  _account = account;
}


#pragma mark Actions

- (void)dismissViewController
{
  if (self.delegate)
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
  else
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAccount:(id)sender
{
  Account *account = (self.account) ? self.account : [Account createEntity];
  
  // if (!account.uid) account.uid = [NSString uuid];
  
  account.name         = self.nameField.text;
  account.usernameText = self.usernameField.text;
  account.passwordText = self.passwordField.text;
  account.categoryText = self.categoryName;
  account.notesText    = [self notesText];
  account.index        = [Account totalOfAccountsInCategory:self.categoryName];
  
  [[NSManagedObjectContext contextForCurrentThread] saveToPersistentStoreAndWait];
  
  [self.delegate accountSaved:account];
  [self dismissViewController];
}

- (IBAction)cancelAccount:(id)sender
{
  [self dismissViewController];
}


#pragma mark NotesViewControllerDelegate

- (NSString *)notesText
{
  return self.notesField.text;
}

- (void)notesUpdated:(NSString *)notes
{
  self.notesField.text = notes;
  
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

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
  if (textField == self.nameField) self.navigationItem.rightBarButtonItem.enabled = NO;
  
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  BOOL canSave = [self.nameField.text isNotEmpty];
  if (textField == self.nameField) canSave = range.location > 0 || [string isNotEmpty];
  
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
    [notesVC setNotes:self.notesField.text];
  }
}


#pragma mark View lifecycle

- (void)syncFromModel
{
  if (!self.syncedFromModel) {
    
    self.nameField.text     = self.account.name;
    self.usernameField.text = self.account.usernameText;
    self.passwordField.text = self.account.passwordText;
    self.notesField.text    = self.account.notesText;
    
    self.syncedFromModel = YES;
  }
}

- (void)enableOrDisableSaveButton
{
  self.navigationItem.rightBarButtonItem.enabled = (self.account != nil);
}

- (void)setNavigationBarTitle
{
  self.navigationItem.title = self.categoryName;
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
  self.notesField = nil;
  [super viewDidUnload];
}


#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([PasswordcogAppDelegate userInterfaceIdiomPad])
    return YES;
  else
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


@end
