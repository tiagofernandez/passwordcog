#import "Account.h"

@implementation Account

@dynamic uuid;
@dynamic name;
@dynamic username;
@dynamic password;
@dynamic category;
@dynamic notes;
@dynamic index;

static NSString *PasswordEncryptionKey = @"fc4546cc213e6a5b972382d05a78979ea8ce819f5a98ce19717a5d91dedca317";

+ (NSData *)encryptPassword:(NSString *)plaintext
{
  return [plaintext encryptWithKey:PasswordEncryptionKey];
}

+ (NSString *)decryptPassword:(NSData *)ciphertext
{
  return [ciphertext decryptWithKey:PasswordEncryptionKey];
}

+ (NSMutableArray *)allAccountsInCategory:(NSString *)category
{
  return [NSMutableArray arrayWithArray:[Account findByAttribute:@"category"
                                                       withValue:category
                                                      andOrderBy:@"index"
                                                       ascending:YES]];
}

+ (NSMutableArray *)allAccountsInCategorySorted:(NSString *)category
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category ==[c] %@", category];
  return [NSMutableArray arrayWithArray:[Account findAllWithPredicate:predicate]];
}

+ (NSString *)totalOfAccountsInCategory:(NSString *)category
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
  NSInteger count = [Account countOfEntitiesWithPredicate:predicate];
  return [NSString stringWithFormat:@"%d", count];
}

@end
