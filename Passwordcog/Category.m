#import "Category.h"

@implementation Category

@dynamic uid;
@dynamic name;
@dynamic imageName;

#pragma mark - Querying

+ (NSString *)categoryIdFromName:(NSString *)name
{
  NSDictionary *categoryNames = [Category allCategoryNames];
  
  for (int i = 0; i < [categoryNames count]; i++) {
    
    NSString *categoryId = [NSString stringWithFormat:@"%d", i];
    NSString *categoryName = [categoryNames objectForKey:categoryId];
    
    if ([name isEqualToString:categoryName])
      return categoryId;
  }
  return nil;
}

+ (NSString *)categoryNameFromId:(NSString *)uid
{
  NSDictionary *categoryNames = [Category allCategoryNames];
  
  for (int i = 0; i < [categoryNames count]; i++) {
    
    NSString *categoryId = [NSString stringWithFormat:@"%d", i];
    NSString *categoryName = [categoryNames objectForKey:categoryId];
    
    if ([uid isEqualToString:categoryId])
      return categoryName;
  }
  return nil;
}

/*
+ (NSArray *)allCategoriesSorted
{
  NSMutableArray *categories = [NSMutableArray new];
  NSDictionary *categoryNames = [Category allCategoryNames];
  
  for (int i = 0; i < [categoryNames count]; i++) {
    
    NSString *categoryId = [NSString stringWithFormat:@"%d", i];
    NSString *categoryName = [categoryNames objectForKey:categoryId];
    
    Category *category = [Category new];
    category.uid  = categoryId;
    category.name = categoryName;
    
    [categories addObject:category];
  }
  return categories;
}
*/

+ (NSDictionary *)allCategoryNames
{
  NSString* categoryNamesPlist = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
  return [NSDictionary dictionaryWithContentsOfFile:categoryNamesPlist];
}

+ (NSDictionary *)allCategoryImages
{
  NSString* categoryImagesPlist = [[NSBundle mainBundle] pathForResource:@"CategoryImages" ofType:@"plist"];
  return [NSDictionary dictionaryWithContentsOfFile:categoryImagesPlist];
}

@end
