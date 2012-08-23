#import "Category.h"

@implementation Category

@dynamic uid;
@dynamic name;
@dynamic imageName;


#pragma mark - Querying

+ (Category *)categoryFromName:(NSString *)name
{
  return [Category findFirstByAttribute:@"name" withValue:name];
}

+ (NSDictionary *)allCategoryNames
{
  NSDictionary *categories = [NSMutableDictionary dictionaryWithCapacity:[[Category numberOfEntities] intValue]];
  
  for (Category *category in [Category findAll]) {
    [categories setValue:category.name forKey:category.uid];
  }
  return categories;
}

+ (NSDictionary *)allCategoryImages
{
  NSDictionary *images = [NSMutableDictionary dictionaryWithCapacity:[[Category numberOfEntities] intValue]];
  
  for (Category *category in [Category findAll]) {
    [images setValue:category.imageName forKey:category.uid];
  }
  return images;
}


#pragma mark - Default values

+ (void)loadDefaultCategories
{
  if ([[Category numberOfEntities] intValue] == 0) {
    
    NSString* categoriesPlist = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
    NSDictionary *categories = [NSDictionary dictionaryWithContentsOfFile:categoriesPlist];
    
    NSString* categoryImagesPlist = [[NSBundle mainBundle] pathForResource:@"CategoryImages" ofType:@"plist"];
    NSDictionary *categoryImages = [NSDictionary dictionaryWithContentsOfFile:categoryImagesPlist];

    for (int i = 0; i < [categories count]; i++) {
      
      Category *category = [Category createEntity];
      category.uid       = [NSString stringWithFormat:@"%d", i];
      category.name      = [categories objectForKey:category.uid];
      category.imageName = [categoryImages objectForKey:category.uid];
      
      [[NSManagedObjectContext contextForCurrentThread] save];
    }
  }
}

@end
