#import <CoreData/CoreData.h>

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *imageName;

+ (NSString *)categoryIdFromName:(NSString *)name;
+ (NSString *)categoryNameFromId:(NSString *)uid;

//+ (NSArray *)allCategoriesSorted;
+ (NSDictionary *)allCategoryNames;
+ (NSDictionary *)allCategoryImages;

@end
