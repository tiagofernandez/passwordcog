#import "CategoriesViewController.h"
#import "AccountListViewController.h"

#pragma mark Custom UITableViewCell

@interface CategoryImageCell : UITableViewCell
@end

@implementation CategoryImageCell

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.textLabel.frame = CGRectMake(50, 0, 250, 44);
}

@end


@implementation CategoriesViewController

@synthesize categories = _categories;
@synthesize categoryImages = _categoryImages;

- (NSDictionary *)categories
{
  if (!_categories) {
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
    _categories = [NSDictionary dictionaryWithContentsOfFile:plistPath];
  }
  return _categories;
}

- (NSDictionary *)categoryImages
{
  if (!_categoryImages) {
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"CategoryImages" ofType:@"plist"];
    _categoryImages = [NSDictionary dictionaryWithContentsOfFile:plistPath];
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
  if (!cell) cell = [[CategoryImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableCell];
  
  cell.textLabel.text = [self.categories objectForKey:categoryIndex];
  cell.imageView.image = [UIImage imageNamed:[self.categoryImages objectForKey:categoryIndex]];
  
  return cell;
}


#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
  if ([segue.identifier isEqualToString:@"Account List"]) {
    AccountListViewController *accountListVC = segue.destinationViewController;
    [accountListVC setCategory:sender.textLabel.text];
  }
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
