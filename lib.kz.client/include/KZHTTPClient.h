#import <Foundation/Foundation.h>

@interface KZHTTPClient : NSObject

+ (KZHTTPClient*)sharedClient;

- (void)setBasicAuthWithUsername:(NSString*)username password:(NSString*)password;

- (void)GET:(NSString*)path parameters:(NSDictionary*)parameters completion:(void (^)(id response, NSHTTPURLResponse *urlResponse, NSError *error))completionBlock;
- (void)GET:(NSString*)path parameters:(NSDictionary*)parameters saveToPath:(NSString*)savePath progress:(void (^)(float progress))progressBlock completion:(void (^)(id response, NSHTTPURLResponse *urlResponse, NSError *error))completionBlock;

- (void)POST:(NSString*)path parameters:(NSDictionary*)parameters completion:(void (^)(id response, NSHTTPURLResponse *urlResponse, NSError *error))completionBlock;
- (void)PUT:(NSString*)path parameters:(NSDictionary*)parameters completion:(void (^)(id response, NSHTTPURLResponse *urlResponse, NSError *error))completionBlock;
- (void)DELETE:(NSString*)path parameters:(NSDictionary*)parameters completion:(void (^)(id response, NSHTTPURLResponse *urlResponse, NSError *error))completionBlock;

- (void)HEAD:(NSString*)path parameters:(NSDictionary*)parameters completion:(void (^)(id response, NSHTTPURLResponse *urlResponse, NSError *error))completionBlock;

- (void)cancelRequestsWithPath:(NSString*)path;
- (void)cancelAllRequests;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, readwrite) NSDictionary *headers;

@property (nonatomic, readwrite) BOOL sendParametersAsJSON;
@property (nonatomic, readwrite) NSURLRequestCachePolicy cachePolicy;

@property (nonatomic, readwrite) BOOL bypassSSLValidation;

@end
