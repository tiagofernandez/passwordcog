#import <CoreData/CoreData.h>

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *imageName;

+ (Category *)categoryFromName:(NSString *)name;

+ (NSDictionary *)allCategoryNames;
+ (NSDictionary *)allCategoryImages;

+ (void)loadDefaultCategories;

@end
