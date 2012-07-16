#import "Account.h"

@implementation Account

@synthesize uuid = _uuid;
@synthesize service = _service;
@synthesize username = _username;
@synthesize password = _password;
@synthesize category = _category;
@synthesize notes = _notes;

- (id)initWithCategory:(NSString *)category
{
  if ((self = [super init])) {
    self.category = category;
  }
  return self;
}

@end
