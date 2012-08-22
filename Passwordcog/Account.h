#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * username;
@property (nonatomic, retain) NSData * password;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSData * notes;
@property (nonatomic, retain) NSString * index;

- (NSString *)usernameText;
- (void)setUsernameText:(NSString *)username;

- (NSString *)passwordText;
- (void)setPasswordText:(NSString *)password;

- (NSString *)notesText;
- (void)setNotesText:(NSString *)notes;

+ (NSArray *)allAccountsInCategory:(NSString *)category;
+ (NSMutableArray *)allAccountsInCategorySorted:(NSString *)category;
+ (NSString *)totalOfAccountsInCategory:(NSString *)category;

@end
