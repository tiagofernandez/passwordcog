#import "AccountListViewController.h"
#import "NSString+NSStringUtils.h"

@interface AccountListViewController ()

@property (strong, nonatomic) NSMutableDictionary *accounts;
@property (strong, nonatomic) NSArray *categories;

@end


@implementation AccountListViewController

@synthesize accounts = _accounts;
@synthesize categories = _categories;

- (NSMutableDictionary *)accounts
{
  if (!_accounts) {
    _accounts = [NSMutableDictionary new];
    
    for (NSString *category in self.categories)
      [_accounts setObject:[NSMutableArray new] forKey:category];
  }
  return _accounts;
}

- (NSArray *)categories
{
  if (!_categories) {
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
    _categories = [NSArray arrayWithContentsOfFile:plistPath];
  }
  return _categories;
}


#pragma mark AccountViewControllerDelegate

- (void)accountSaved:(Account *)account
{
  if (account.uuid) {
    for (NSString *category in self.categories) {
      NSMutableArray *currentAccounts = [self.accounts objectForKey:category];
      for (Account *currentAccount in currentAccounts) {
        if ([currentAccount.uuid isEqualToString:account.uuid])
          [currentAccounts removeObject:account];
      }
    }
  }
  else {
    account.uuid = [NSString uuid];
  }
  
  [[self.accounts objectForKey:account.category] addObject:account];
  [self.tableView reloadData];
}


#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [self.categories count];
}

- (NSString *)categoryInSection:(NSInteger)section
{
  return [self.categories objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [self categoryInSection:section];
}

- (Account *)accountAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *category = [self categoryInSection:indexPath.section];
  NSArray *currentAccounts = [self.accounts objectForKey:category];
  
  return ([currentAccounts count] > indexPath.row) ?
    (Account *) [currentAccounts objectAtIndex:indexPath.row] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSString *category = [self categoryInSection:section];
  return [[self.accounts objectForKey:category] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *TableCell = @"Account Cell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableCell];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableCell];
  
  Account *account = [self accountAtIndexPath:indexPath];
  
  cell.textLabel.text = account.service;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", account.username, account.password];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self performSegueWithIdentifier:@"Edit Account" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Account *account   = [self accountAtIndexPath:indexPath];
    NSString *category = [self categoryInSection:indexPath.section];
    
    [[self.accounts objectForKey:category] removeObject:account];
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

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  NSString *previousCategory = [self categoryInSection:sourceIndexPath.section];
  NSString *newCategory      = [self categoryInSection:destinationIndexPath.section];
  
  Account *account = [self accountAtIndexPath:sourceIndexPath];
  [[self.accounts objectForKey:previousCategory] removeObject:account];

  account.category = newCategory;
  [[self.accounts objectForKey:newCategory] insertObject:account atIndex:destinationIndexPath.row];
}


#pragma mark Segue

- (Account *)selectedAccount
{
  NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
  return [self accountAtIndexPath:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier containsString:@"Account"]) {
    AccountViewController *accountVC = [[segue.destinationViewController viewControllers] objectAtIndex:0];
    [accountVC setDelegate:self];
    [accountVC setAccount:[self selectedAccount]];
  }
  else if ([segue.identifier isEqualToString:@"Settings"]) {
    // Nothing for now
  }
}


#pragma mark View lifecycle

- (void)setEditButton
{
  self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setEditButton];
}

- (void)viewDidUnload
{
  // e.g. self.myOutlet = nil;
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
