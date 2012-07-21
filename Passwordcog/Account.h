#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * index;

+ (NSArray *)allAccountsInCategory:(NSString *)category;
+ (NSString *)totalOfAccountsInCategory:(NSString *)category;

@end
