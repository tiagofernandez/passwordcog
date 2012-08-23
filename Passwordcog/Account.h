#import <CoreData/CoreData.h>

#import "Category.h"

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSData *username;
@property (nonatomic, retain) NSData *password;
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSData *notes;
@property (nonatomic, retain) NSString *index;

- (NSString *)categoryText;
- (void)setCategoryText:(NSString *)categoryName;

- (NSString *)usernameText;
- (void)setUsernameText:(NSString *)username;

- (NSString *)passwordText;
- (void)setPasswordText:(NSString *)password;

- (NSString *)notesText;
- (void)setNotesText:(NSString *)notes;

+ (NSArray *)allAccountsInCategory:(NSString *)categoryName;
+ (NSMutableArray *)allAccountsInCategorySorted:(NSString *)categoryName;

+ (NSString *)totalOfAccountsInCategory:(NSString *)categoryName;

@end
