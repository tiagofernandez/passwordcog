#import <CoreData/CoreData.h>

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *imageName;

+ (Category *)categoryFromName:(NSString *)name;
+ (Category *)categoryFromId:(NSString *)uid;

+ (NSSet *)allCategoriesSorted;
+ (NSDictionary *)allCategoryNames;
+ (NSDictionary *)allCategoryImages;

+ (void)loadDefaultCategories;

@end
