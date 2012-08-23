#import <UIKit/UIKit.h>

#import "AccountViewController.h"

@protocol AccountListViewControllerDelegate <NSObject>

@optional

- (void)categoryModified:(NSString *)categoryName;

@end


@interface AccountListViewController : UITableViewController <AccountViewControllerDelegate>

@property (weak, nonatomic) id<AccountListViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *categoryName;

- (void)reloadWithCategory:(NSString *)categoryName;

@end
