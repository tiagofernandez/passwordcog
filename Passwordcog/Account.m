#import "Account.h"

@implementation Account

@dynamic uuid;
@dynamic name;
@dynamic username;
@dynamic password;
@dynamic category;
@dynamic notes;
@dynamic index;

+ (NSMutableArray *)allAccountsInCategory:(NSString *)category
{
  return [NSMutableArray arrayWithArray:[Account findByAttribute:@"category"
                                                       withValue:category
                                                      andOrderBy:@"index"
                                                       ascending:YES]];
}

+ (NSMutableArray *)allAccountsInCategorySorted:(NSString *)category
{
  return [NSMutableArray arrayWithArray:[Account findByAttribute:@"category"
                                                       withValue:category
                                                      andOrderBy:@"name"
                                                       ascending:YES]];
}

+ (NSString *)totalOfAccountsInCategory:(NSString *)category
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
  NSInteger count = [Account countOfEntitiesWithPredicate:predicate];
  return [NSString stringWithFormat:@"%d", count];
}

@end
