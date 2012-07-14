#import <UIKit/UIKit.h>

#import "Account.h"

@protocol AccountViewControllerDelegate <NSObject>

- (void)accountSaved:(Account *)account;

@end


@interface AccountViewController : UITableViewController

@property (strong, nonatomic) Account *account;

@property (weak, nonatomic) id<AccountViewControllerDelegate> delegate;

@end
