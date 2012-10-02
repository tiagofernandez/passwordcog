#import <UIKit/UIKit.h>

#import "Account.h"

@protocol AccountViewControllerDelegate <NSObject>

- (void)accountSaved:(Account *)account;

@end


@interface AccountViewController : UITableViewController

@property (weak, nonatomic) id<AccountViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) Account *account;

@end
