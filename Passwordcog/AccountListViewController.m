#import "AccountListViewController.h"
#import "NSString+NSStringUtils.h"

@interface AccountListViewController ()

@property (strong, nonatomic) NSMutableArray *accounts;

@end


@implementation AccountListViewController

@synthesize category = _category;
@synthesize accounts = _accounts;

- (void)refreshAccounts
{
  [_accounts removeAllObjects];
  [_accounts addObjectsFromArray:[Account allAccountsInCategory:self.category]];
}

- (NSMutableArray *)accounts
{
  if (!_accounts) {
    _accounts = [NSMutableArray new];
    [self refreshAccounts];
  }
  return _accounts;
}


#pragma mark AccountViewControllerDelegate

- (void)accountSaved:(Account *)account
{
  if (![self.accounts containsObject:account]) {
    [self.accounts addObject:account];
  }
  [self.tableView reloadData];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *TableCell = @"Account Cell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableCell];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableCell];
  
  Account *account = [self accountAtIndexPath:indexPath];
  
  NSString *username = [account.username isNotEmpty] ? account.username : @"N/A";
  NSString *password = [account.password isNotEmpty] ? account.password : @"N/A";
  
  cell.textLabel.text = account.name; // [NSString stringWithFormat:@"(%@) %@", account.index, account.name];
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", username, password];
  
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
  [accountVC setCategory:self.category];
  
  if ([segue.identifier containsString:@"Edit Account"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [accountVC setAccount:[self accountAtIndexPath:indexPath]];
  }
}


#pragma mark View lifecycle

- (void)setEditButton
{
  UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  [self setToolbarItems:[NSArray arrayWithObjects:flexibleSpace, self.editButtonItem, nil]];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setEditButton];
  [self setTitle:self.category];
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
