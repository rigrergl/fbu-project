//
//  APIManager.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import "APIManager.h"

@interface APIManager()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation APIManager

- (id)init {
    self = [super init];
    
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    return self;
}

- (void)fetchArtist:(NSString *)artistId
     withCompletion:(void(^)(NSDictionary *_Nullable responseDictionary,NSError *_Nullable error))completion {
    NSString *urlString = [NSString stringWithFormat:@"https://theaudiodb.com/api/v1/json/1/search.php?s=%@", artistId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(responseDictionary, nil);
        } else {
            completion(nil, error);
        }
    }];
    [task resume];
}

@end
