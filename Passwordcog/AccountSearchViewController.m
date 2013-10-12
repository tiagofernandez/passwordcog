#import "AccountSearchViewController.h"
#import "Account.h"
#import "AccountViewController.h"
#import "Category.h"

@interface AccountSearchViewController ()

@property (strong, nonatomic) NSMutableArray *searchResults;

@property BOOL shouldPresentKeyboard;

@end

@implementation AccountSearchViewController

@synthesize searchResults = _searchResults;

- (NSMutableArray *)searchResults
{
  if (!_searchResults) {
    _searchResults = [NSMutableArray new];
  }
  return _searchResults;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  [self.searchResults removeAllObjects];
  [self.searchResults addObjectsFromArray:[Account searchAccountsWithNameLike:searchText]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchDisplayDelegate

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
  controller.searchBar.showsCancelButton = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *TableCell = @"Search Cell";
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableCell];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableCell];
  
  Account *account = [self.searchResults objectAtIndex:indexPath.row];
  
  cell.textLabel.text = account.name;
  
  return cell;
}

#pragma mark - UITableViewDelegate

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  NSIndexPath *selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];

  Account *account = [self.searchResults objectAtIndex:selectedIndexPath.row];
  NSString *categoryName = [Category categoryNameFromId:account.categoryId];
  
  AccountViewController *accountVC = segue.destinationViewController;
  [accountVC setCategoryName:categoryName];
  [accountVC setAccount:account];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if (self.shouldPresentKeyboard) {
    [self.searchDisplayController.searchBar becomeFirstResponder];
    self.shouldPresentKeyboard = NO; // so when getting back from a search result, the keyboard is not presented.
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.shouldPresentKeyboard = YES;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

#pragma mark - UIViewControllerRotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([PasswordcogAppDelegate userInterfaceIdiomPad])
    return YES;
  else
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
