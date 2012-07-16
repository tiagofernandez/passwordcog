#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *service;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *notes;

- (id)initWithCategory:(NSString *)category;

@end
