#import "MainViewController.h"
#import "NSData+GZIP.h"
#import "NSString+NSStringAdditions.h"
#import <KZApplication.h>

#define kAssociateService   @"http://jmscservices.jmfamily.com/"
#define kGoogleDriveScope   @"GetGoogleToken/Token?scope=https://www.googleapis.com/auth/calendar"
#define kOAuthServiceURL    @"https://az.jmfamily.com/authserver/jmassociate/oauth/token"
#define kOAuthAudience      @"jmassociate"
#define kOAuthNamespace     @"jmassociate"
#define kOAuthClientId      @"ios"
#define kOAuthClientSecret  @"08RTYmhu9IRwiJlfDK27wvQQ7qq9q9hE85r7XGaxJo"
#define kOAuthScope         @"All"


#define userName        @"CONPFYH"
#define password        @"t0y0ta1!"
#define scope           @"All"

#define clientId        @"ios"
#define clientSecret    @"08RTYmhu9IRwiJlfDK27wvQQ7qq9q9hE85r7XGaxJo"


#define kidoMarketplace @"https://tellago.kidocloud.com"
#define kidoApplication @"tasks"
#define kidoAccount     @"tellago@kidozen.com"
#define kidoAccountPass @"pass"
#define kidoAPIName     @"GDrive-OAuth"
#define kidoAPIMethod   @"GetAbout"
#define kidoProvider    @"Kidozen"

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    textView.text = @"Ready.";
}


-(IBAction)signIn
{
    
    NSString *oauth_token = [self getOAuth2Token];
    textView.text = oauth_token;
    
    [self InvokeKidoZenEAPI:oauth_token];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([textView isFirstResponder] && [touch view] != textView) {
        [textView resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (NSString *) getOAuth2Token {
    NSLog(@"Logging in user");
    NSString *strAuthorizationKey = [NSString base64StringFromString:[NSString stringWithFormat:@"%@:%@", clientId, clientSecret]];
    
    strAuthorizationKey = [NSString stringWithFormat: @"Basic %@", strAuthorizationKey];
    NSMutableDictionary *headersList = [[NSMutableDictionary alloc]init];
    [headersList setValue:strAuthorizationKey forKey:@"Authorization"];
    
    NSURL *url=[NSURL URLWithString:@"https://az.jmfamily.com/AuthServer/jmassociate/oauth/token"];
    
    NSString *post =[NSString stringWithFormat:@"grant_type=password&username=%@&password=%@&scope=%@", userName, password, scope];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setAllHTTPHeaderFields:headersList];
    
    NSError *error;
    NSURLResponse *response;
    
    NSLog(@"Sending Login Request");
    NSData *tokenResponse=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"Received Login Response");
    
    //Get the access_token from the response
    NSError *jsonerror;
    NSString *accessToken =  [[NSJSONSerialization JSONObjectWithData:tokenResponse options:0 error:&jsonerror]
                              objectForKey:@"access_token"];
    
    //Zip the access_token
    NSData *zippedToken = [[[NSData alloc]initWithData:[accessToken dataUsingEncoding:NSUTF8StringEncoding]]
                           gzippedData];
    
    //Encode the zipped access_token to Base64 string
    NSString *base64ZippedToken =  [NSString base64StringFromData:zippedToken length:zippedToken.length];
    
    NSString * gDriveToken = [self getGoogleDriveToken:base64ZippedToken];
    
    NSLog(@"Google Drive OAuthToken: %@",gDriveToken);
    return gDriveToken;
}

- (NSString *) getGoogleDriveToken: (NSString *) access_token {
    NSLog(@"Getting Google Drive Token");
    
    NSString *strAuthorizationKey = [NSString stringWithFormat: @"Bearer %@",access_token];
    NSMutableDictionary *headersList = [[NSMutableDictionary alloc]init];
    [headersList setValue:strAuthorizationKey forKey:@"Authorization"];
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kAssociateService, kGoogleDriveScope]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headersList];
    
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *gdriveResponseData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //Get the access_token from the response
    NSError *jsonerror;
    NSString * gDriveAccessToken =  [[NSJSONSerialization JSONObjectWithData:gdriveResponseData options:0 error:&jsonerror]
                                     objectForKey:@"access_token"];
    
    return gDriveAccessToken;
}

//KidoZen App Setup
- (void) InvokeKidoZenEAPI : (NSString *) token
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    KZApplication * app = [[KZApplication alloc] initWithTennantMarketPlace:kidoMarketplace applicationName:kidoApplication bypassSSLValidation:YES andCallback:^(KZResponse * r) {
        [self authBlock:semaphore token:token r:r];
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    assert(app);
}

//KidoZen SDK auth callback
- (void)authBlock:(dispatch_semaphore_t)semaphore token:(NSString *)token r:(KZResponse *)r
{
    [r.application authenticateUser:kidoAccount withProvider:kidoProvider andPassword:kidoAccountPass completion:^(id c) {
        KZService *gDriveService = [r.application LOBServiceWithName:kidoAPIName];
        NSDictionary * getAboutOptions = [NSDictionary dictionaryWithObjectsAndKeys:token,@"access_token", nil];
        NSLog(@"Calling 'GetAbout' method in GDrive");
        [gDriveService invokeMethod:kidoAPIMethod withData:getAboutOptions completion:^(KZResponse * ar) {
            NSString * response = [NSString stringWithFormat:@"GDrive response: %@",ar.response];
            textView.text = response;
            NSLog(response);
            dispatch_semaphore_signal(semaphore);
        }];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end