#import <UIKit/UIKit.h>

#import "AccountViewController.h"

@interface AccountListViewController : UITableViewController <AccountViewControllerDelegate>

@property (strong, nonatomic) NSString *category;

- (void)reloadWithCategory:(NSString *)category;

@end
