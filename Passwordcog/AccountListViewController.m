#import "AccountListViewController.h"

@interface AccountListViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *emptyAccountListView;
@property (strong, nonatomic) IBOutlet UIImageView *passwordKeyView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sortButton;

@property (strong, nonatomic) NSMutableArray *accounts;

@end


@implementation AccountListViewController

@synthesize delegate = _delegate;

@synthesize emptyAccountListView = _emptyAccountListView;
@synthesize passwordKeyView = _passwordKeyView;

@synthesize addButton = _addButton;
@synthesize sortButton = _sortButton;

@synthesize categoryName = _categoryName;
@synthesize accounts = _accounts;

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
  
  [self.tableView reloadData];
}


#pragma mark Actions

- (IBAction)sortAccounts:(UIBarButtonItem *)sender
{
  [self refreshAccountsWithData:[Account allAccountsInCategorySorted:self.categoryName]];
  
  [self.tableView reloadData];
  [self refreshIndices];
}


#pragma mark AccountViewControllerDelegate

- (void)accountSaved:(Account *)account
{
  if (![self.accounts containsObject:account]) {
    [self.accounts addObject:account];
  }
  [self showOrHideSubviews];
  [self.tableView reloadData];
  
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
  
  cell.textLabel.text = account.name; // [NSString stringWithFormat:@"(%@) %@", account.index, account.name];
  cell.detailTextLabel.text = [self detailTextForAccount:account];
  
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
    
    [[NSManagedObjectContext contextForCurrentThread] save];
    
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

- (void)refreshIndices
{
  for (int index = 0; index < [self.accounts count]; index++) {
    Account *account = [self.accounts objectAtIndex:index];
    account.index = [NSString stringWithFormat:@"%d", index];
  }
  [[NSManagedObjectContext contextForCurrentThread] save];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  Account *sourceAccount = [self accountAtIndexPath:sourceIndexPath];
  
  [self.accounts removeObject:sourceAccount];
  [self.accounts insertObject:sourceAccount atIndex:destinationIndexPath.row];
  
  [self refreshIndices];
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
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  [self setToolbarItems:[NSArray arrayWithObjects:self.sortButton, flexibleSpace, self.editButtonItem, nil]];
}

- (void)showOrHideSubviews
{
  [self.passwordKeyView removeFromSuperview];
  [self.emptyAccountListView removeFromSuperview];
  
  BOOL emptyAccounts = [self.accounts count] == 0;
  
  if (!self.categoryName) {
    self.passwordKeyView.center = self.tableView.center;
    [self.tableView addSubview:self.passwordKeyView];
  }
  else if (emptyAccounts) {
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

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setToolbarItems];
  [self setTitle:self.categoryName];
}

- (void)viewDidUnload
{
  self.emptyAccountListView = nil;
  self.passwordKeyView = nil;
  self.addButton = nil;
  self.sortButton = nil;
  [super viewDidUnload];
}


#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return [PasswordcogAppDelegate userInterfaceIdiomPad];
}


@end
