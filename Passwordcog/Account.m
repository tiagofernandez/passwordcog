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
  if (!_category) _category = @"Internet";
  return _category;
}

@end
