#import "AccountListViewController.h"
#import "Settings.h"

@interface CopyUsernamePasswordGestureRecognizer : UILongPressGestureRecognizer
@property (strong, nonatomic) Account *targetAccount;
@end

@implementation CopyUsernamePasswordGestureRecognizer
@synthesize targetAccount = _targetAccount;
@end


@interface AccountListViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *emptyAccountListView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sortButton;

@property (strong, nonatomic) NSMutableArray *accounts;

@property (strong, nonatomic) CopyUsernamePasswordGestureRecognizer *ongoingCopyUsernamePasswordGesture;

@property (nonatomic, strong) NSTimer *refreshTimer;

@end


@implementation AccountListViewController

@synthesize delegate = _delegate;

@synthesize emptyAccountListView = _emptyAccountListView;

@synthesize addButton = _addButton;
@synthesize sortButton = _sortButton;

@synthesize categoryName = _categoryName;
@synthesize accounts = _accounts;

@synthesize ongoingCopyUsernamePasswordGesture = _ongoingCopyUsernamePasswordGesture;

- (void)refreshAccountsWithData:(NSArray *)data
{
  [self.accounts removeAllObjects];
  [self.accounts addObjectsFromArray:data];
}

- (NSMutableArray *)accounts
{
  if (!_accounts) {
    _accounts = [NSMutableArray new];
    
    [self refreshAccountsWithData:[Account allAccountsInCategory:self.categoryName]];
  }
  return _accounts;
}


#pragma mark Public interface

- (void)reloadWithCategory:(NSString *)categoryName
{
  self.categoryName = categoryName;
  
  [self setTitle:self.categoryName];
  [self refreshAccountsWithData:[Account allAccountsInCategory:self.categoryName]];
  [self showOrHideSubviews];
  [self enableOrDisableButtons];
  
  [self refreshView];
}


#pragma mark Actions

- (IBAction)sortAccounts:(UIBarButtonItem *)sender
{
  [self refreshAccountsWithData:[Account allAccountsInCategorySorted:self.categoryName]];
  
  [self refreshView];
  [self refreshIndices];
}


#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  Account *account = self.ongoingCopyUsernamePasswordGesture.targetAccount;
  
  if (buttonIndex == 0)
    [[UIPasteboard generalPasteboard] setString:account.usernameText];
  
  else if (buttonIndex == 1)
    [[UIPasteboard generalPasteboard] setString:account.passwordText];
}

- (void)showCopyUsernameOrPasswordSheet:(CopyUsernamePasswordGestureRecognizer *)gesture
{
  if (![self.tableView isEditing] && gesture.state == UIGestureRecognizerStateBegan) {
    UIActionSheet *copyOptionsSheet = [[UIActionSheet alloc] initWithTitle:@"Clipboard"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"Copy username", @"Copy password", nil];
    
    self.ongoingCopyUsernamePasswordGesture = gesture;
    [copyOptionsSheet showFromToolbar:self.navigationController.toolbar];
  }
}


#pragma mark AccountViewControllerDelegate

- (void)accountSaved:(Account *)account
{
  if (![self.accounts containsObject:account]) {
    [self.accounts addObject:account];
  }
  [self showOrHideSubviews];
  [self refreshIndices];
  [self refreshView];
  
  [self.delegate categoryModified:self.categoryName];
}


#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.accounts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 55;
}

- (Account *)accountAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.accounts objectAtIndex:indexPath.row];
}

- (NSString *)detailTextForAccount:(Account *)account
{
  NSString *username = account.usernameText;
  NSString *password = account.passwordText;
  
  username = [username isNotEmpty] ? username : @"N/A";
  password = [password isNotEmpty] ? password : @"N/A";
  
  NSString *detailText = [NSString stringWithFormat:@"%@ - %@", username, password];
  return [detailText isEqualToString:@"N/A - N/A"] && [account.notesText isNotEmpty]? account.notesText : detailText;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *TableCell = @"Account Cell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableCell];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableCell];
  
  Account *account = [self accountAtIndexPath:indexPath];
  
  cell.textLabel.text = account.name;
  cell.detailTextLabel.text = [Settings hidePasswords] ? @"" : [self detailTextForAccount:account];
  
  CopyUsernamePasswordGestureRecognizer *copyUsernamePasswordGesture =
    [[CopyUsernamePasswordGestureRecognizer alloc] initWithTarget:self action:@selector(showCopyUsernameOrPasswordSheet:)];
  
  copyUsernamePasswordGesture.targetAccount = account;
  
  [cell addGestureRecognizer:copyUsernamePasswordGesture];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"Edit Account" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    Account *account = [self accountAtIndexPath:indexPath];
    [account deleteEntity];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    [localContext saveToPersistentStoreAndWait];
    
    [self.accounts removeObject:account];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    
    [self.delegate categoryModified:self.categoryName];
  }  
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  Account *sourceAccount = [self accountAtIndexPath:sourceIndexPath];
  
  [self.accounts removeObject:sourceAccount];
  [self.accounts insertObject:sourceAccount atIndex:destinationIndexPath.row];
  
  [self refreshIndices];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
  [super setEditing:editing animated:animated];
  
  if (editing == YES)
    [self disableAllCopyUsernamePasswordGestureRecognizers];
  else
    [self enableAllCopyUsernamePasswordGestureRecognizers];
}

- (void)refreshIndices
{
  for (int index = 0; index < [self.accounts count]; index++) {
    Account *account = [self.accounts objectAtIndex:index];
    account.index = [NSString stringWithFormat:@"%d", index];
  }
  NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
  [localContext saveToPersistentStoreAndWait];
}


#pragma mark Gesture recognizer

- (void)disableAllCopyUsernamePasswordGestureRecognizers
{
  [self iterateCopyUsernamePasswordGestureRecognizersWithBlock:^(UIGestureRecognizer *gestureRecognizer) {
    gestureRecognizer.enabled = NO;
  }];
}

- (void)enableAllCopyUsernamePasswordGestureRecognizers
{
  [self iterateCopyUsernamePasswordGestureRecognizersWithBlock:^(UIGestureRecognizer *gestureRecognizer) {
    gestureRecognizer.enabled = YES;
  }];
}

- (void)iterateCopyUsernamePasswordGestureRecognizersWithBlock:(void (^)(UIGestureRecognizer *recognizer))block
{
  for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j) {
    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i) {
      UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
      for (UIGestureRecognizer *gestureRecognizer in cell.gestureRecognizers) block(gestureRecognizer);
    }
  }
}


#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  AccountViewController *accountVC = [[segue.destinationViewController viewControllers] objectAtIndex:0];
  [accountVC setDelegate:self];
  [accountVC setCategoryName:self.categoryName];
  
  if ([segue.identifier containsString:@"Edit Account"]) {

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:NO];
    
    [accountVC setAccount:[self accountAtIndexPath:indexPath]];
  }
}


#pragma mark View lifecycle

- (void)setToolbarItems
{
  self.editButtonItem.tintColor = [UIColor darkGrayColor];
  
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  [self setToolbarItems:[NSArray arrayWithObjects:self.sortButton, flexibleSpace, self.editButtonItem, nil]];
}

- (void)showOrHideSubviews
{
  [self.emptyAccountListView removeFromSuperview];
  
  BOOL emptyAccounts = [self.accounts count] == 0;
  
  if (self.categoryName && emptyAccounts) {
    CGFloat xPosition = CGRectGetWidth(self.tableView.frame) - CGRectGetWidth(self.emptyAccountListView.frame);
    self.emptyAccountListView.center = CGPointMake(ceil(xPosition) + 160, 40.0);
    [self.tableView addSubview:self.emptyAccountListView];
  }
  self.tableView.bounces = !emptyAccounts;
}

- (void)enableOrDisableButtons
{
  BOOL categorySelected = (self.categoryName != nil);
  
  self.addButton.enabled      = categorySelected;
  self.editButtonItem.enabled = categorySelected;
  self.sortButton.enabled     = categorySelected;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self enableOrDisableButtons];
  [self showOrHideSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(reloadView)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [self.refreshTimer invalidate];
  self.refreshTimer = nil;
  
  [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self setToolbarItems];
  [self setTitle:self.categoryName];
}

- (void)viewDidUnload
{
  self.emptyAccountListView = nil;
  self.addButton = nil;
  self.sortButton = nil;
  
  [super viewDidUnload];
}

- (void)reloadView
{
  if (![self.tableView isEditing])
    [self reloadWithCategory:self.categoryName];
}

- (void)refreshView
{
  [self.tableView reloadData];
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
