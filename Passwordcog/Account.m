#import "Account.h"

@implementation Account

@synthesize uuid = _uuid;
@synthesize service = _service;
@synthesize username = _username;
@synthesize password = _password;
@synthesize category = _category;
@synthesize notes = _notes;

- (NSString *)category
{
  if (!_category) {
    _category = [[Account allCategories] objectForKey:@"5"];
  }
  return _category;
}

+ (NSDictionary *)allCategories
{
  NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
  return [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

+ (NSDictionary *)allCategoryImages
{
  NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"CategoryImages" ofType:@"plist"];
  return [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

@end
