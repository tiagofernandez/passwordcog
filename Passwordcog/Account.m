#import "Account.h"

@implementation Account

@dynamic uuid;
@dynamic name;
@dynamic username;
@dynamic password;
@dynamic categoryId;
@dynamic notes;
@dynamic index;


#pragma mark - Helpers

- (NSString *)categoryText
{
  Category *category = [Category findFirstByAttribute:@"uuid" withValue:self.categoryId];
  return category.name;
}

- (void)setCategoryText:(NSString *)categoryName
{
  Category *category = [Category categoryFromName:categoryName];
  self.categoryId = category.uuid;
}

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

+ (NSMutableArray *)allAccountsInCategory:(NSString *)categoryName
{
  if (categoryName) {
    Category *category = [Category categoryFromName:categoryName];
    
    return [NSMutableArray arrayWithArray:[Account findByAttribute:@"categoryId"
                                                       withValue:category.uuid
                                                      andOrderBy:@"index"
                                                       ascending:YES]];
  }
  else return nil;
}

+ (NSMutableArray *)allAccountsInCategorySorted:(NSString *)categoryName
{
  Category *category = [Category categoryFromName:categoryName];
  NSArray *accounts  = [Account findByAttribute:@"categoryId" withValue:category.uuid];

  NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                         ascending:YES
                                                          selector:@selector(caseInsensitiveCompare:)];
  
  return [NSMutableArray arrayWithArray:[accounts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]]];
}

+ (NSString *)totalOfAccountsInCategory:(NSString *)categoryName
{
  Category *category = [Category categoryFromName:categoryName];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId == %@", category.uuid];
  
  return [NSString stringWithFormat:@"%d", [Account countOfEntitiesWithPredicate:predicate]];
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
