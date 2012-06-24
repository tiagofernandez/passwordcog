#import "AccountViewController.h"
#import "BlockAlertView.h"
#import "CategoryViewController.h"
#import "NotesViewController.h"
#import "NSString+NSStringUtils.h"

@interface AccountViewController () <UITextFieldDelegate, CategoryViewControllerDelegate, NotesViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *serviceField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) Account *account;

@end


@implementation AccountViewController

@synthesize delegate = _delegate;

@synthesize serviceField = _serviceField;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

@synthesize account = _account;

- (Account *)account
{
  if (!_account) _account = [Account new];
  return _account;
}


#pragma mark Actions

- (void)dismissViewController
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (NSArray *)missingFields
{
  NSMutableArray *missingFields = [NSMutableArray arrayWithCapacity:3];
  
  if ([self.serviceField.text isEmpty])  [missingFields addObject:@"service"];
  if ([self.usernameField.text isEmpty]) [missingFields addObject:@"username"];
  if ([self.passwordField.text isEmpty]) [missingFields addObject:@"password"];
  
  return missingFields;
}

- (IBAction)saveAccount:(id)sender
{
  NSArray *missingFields = [self missingFields];
  
  if ([missingFields count] == 0) {
    
    self.account.service = self.serviceField.text;
    self.account.username = self.usernameField.text;
    self.account.password = self.passwordField.text;
    
    [self.delegate accountSaved:self.account];
    [self dismissViewController];
  }
  else {
    NSString *errorMessage = [NSString stringWithFormat:@"Please enter the field(s):\n%@.",
                [missingFields componentsJoinedByString:@", "]];
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Missing fields"
                                                   message:errorMessage];
    [alert addButtonWithTitle:@"OK" block:nil];
    [alert show];
  }
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
  [self.tableView reloadData];
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
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.serviceField)
    [self.usernameField becomeFirstResponder];
  
  else if (textField == self.usernameField)
    [self.passwordField becomeFirstResponder];
  
  else if (textField == self.passwordField)
    [self performSegueWithIdentifier:@"Category" sender:self];
  
  return YES;
}


#pragma mark UITableViewDataSource & UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
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

//- (void)setViewBackground
//{
//  UIImage *background = [UIImage imageNamed:@"light_gray_noise_background.png"];
//  self.view.backgroundColor = [UIColor colorWithPatternImage:background];
//  self.view.opaque = NO;
//}

- (void)initTextFields
{
  self.serviceField.delegate = self;
  self.usernameField.delegate = self;
  self.passwordField.delegate = self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
//  [self setViewBackground];
  [self initTextFields];
}

- (void)viewDidUnload
{
  self.serviceField = nil;
  self.usernameField = nil;
  self.passwordField = nil;
  [super viewDidUnload];
}

@end
