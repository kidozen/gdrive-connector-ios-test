
#import "KZBaseService.h"

@interface KZService : KZBaseService

-(void) invokeMethod:(NSString *) method withData:(id)data completion:(void (^)(KZResponse *))block;

@end
