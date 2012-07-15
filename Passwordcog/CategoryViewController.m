#import "CategoryViewController.h"
#import "Account.h"

@interface CategoryViewController ()

@property (strong, nonatomic) NSDictionary *categories;
@property (strong, nonatomic) NSDictionary *categoryImages;

@end


@implementation CategoryViewController

@synthesize delegate = _delegate;

@synthesize category = _category;
@synthesize categories = _categories;
@synthesize categoryImages = _categoryImages;

- (NSDictionary *)categories
{
  if (!_categories) {
    _categories = [Account allCategories];
  }
  return _categories;
}

- (NSDictionary *)categoryImages
{
  if (!_categoryImages) {
    _categoryImages = [Account allCategoryImages];
  }
  return _categoryImages;
}


#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *TableCell = @"Category Cell";
  NSString *categoryIndex = [NSString stringWithFormat:@"%d", indexPath.row];
  
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableCell];
  if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableCell];
  
  cell.textLabel.text = [self.categories objectForKey:categoryIndex];
  cell.imageView.image = [UIImage imageNamed:[self.categoryImages objectForKey:categoryIndex]];
  
  return cell;
}

- (UITableViewCell *)categoryCellAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)categoryAtIndexPath:(NSIndexPath *)indexPath
{
  return [self categoryCellAtIndexPath:indexPath].textLabel.text;
}

- (void)checkCategoryAtIndexPath:(NSIndexPath *)indexPath
{
  [self categoryCellAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self checkCategoryAtIndexPath:indexPath];
  [self.delegate categorySelected:[self categoryAtIndexPath:indexPath]];
  [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark View lifecycle

- (void)checkCurrentCategory
{
  for (int index = 0; index < [self.tableView numberOfRowsInSection:0]; index++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:self.category]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self checkCurrentCategory];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  else
    return YES;
}

@end
