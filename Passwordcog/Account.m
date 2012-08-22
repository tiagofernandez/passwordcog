#import "Account.h"

@implementation Account

@dynamic uuid;
@dynamic name;
@dynamic username;
@dynamic password;
@dynamic category;
@dynamic notes;
@dynamic index;


#pragma mark - Helpers

- (NSString *)usernameText
{
  return [Account decrypt:self.username];
}

- (void)setUsernameText:(NSString *)username
{
  self.username = [Account encrypt:username];
}

- (NSString *)passwordText
{
  return [Account decrypt:self.password];
}

- (void)setPasswordText:(NSString *)password
{
  self.password = [Account encrypt:password];
}

- (NSString *)notesText
{
  return [Account decrypt:self.notes];
}

- (void)setNotesText:(NSString *)notes
{
  self.notes = [Account encrypt:notes];
}


#pragma mark - Querying

+ (NSMutableArray *)allAccountsInCategory:(NSString *)category
{
  if (category)
    return [NSMutableArray arrayWithArray:[Account findByAttribute:@"category"
                                                       withValue:category
                                                      andOrderBy:@"index"
                                                       ascending:YES]];
  else return nil;
}

+ (NSMutableArray *)allAccountsInCategorySorted:(NSString *)category
{
  NSArray *accounts = [Account findByAttribute:@"category" withValue:category];

  NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                         ascending:YES
                                                          selector:@selector(caseInsensitiveCompare:)];
  
  return [NSMutableArray arrayWithArray:[accounts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]]];
}

+ (NSString *)totalOfAccountsInCategory:(NSString *)category
{
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
  NSInteger count = [Account countOfEntitiesWithPredicate:predicate];
  return [NSString stringWithFormat:@"%d", count];
}


#pragma mark - Encryption/decryption

static NSString *PasswordEncryptionKey = @"fc4546cc213e6a5b972382d05a78979ea8ce819f5a98ce19717a5d91dedca317";

+ (NSData *)encrypt:(NSString *)plaintext
{
  return [plaintext encryptWithKey:PasswordEncryptionKey];
}

+ (NSString *)decrypt:(NSData *)ciphertext
{
  return [ciphertext decryptWithKey:PasswordEncryptionKey];
}


@end
