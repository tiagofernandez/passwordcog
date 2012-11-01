#import "AccountSearchViewController.h"
#import "Account.h"
#import "AccountViewController.h"
#import "Category.h"

@interface AccountSearchViewController ()

@property (strong, nonatomic) NSMutableArray *searchResults;

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

#pragma mark - Actions

- (IBAction)done:(UIBarButtonItem *)sender
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
  [self.searchResults removeAllObjects];
  [self.searchResults addObjectsFromArray:[Account searchAccountsWithNameLike:searchText]];
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
  //[self.searchDisplayController.searchBar becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([PasswordcogAppDelegate userInterfaceIdiomPad])
    return YES;
  else
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end

#pragma mark - UISearchDisplayController

@interface CustomSearchDisplayController : UISearchDisplayController
@end

@implementation CustomSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
  [super setActive:NO animated:animated];
  [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
}

@end

#pragma mark - UISearchBar

@interface CustomSearchBar : UISearchBar
@end

@implementation CustomSearchBar

-(void)layoutSubviews
{
  [super layoutSubviews];
  [self setShowsCancelButton:NO animated:NO];
}

@end
