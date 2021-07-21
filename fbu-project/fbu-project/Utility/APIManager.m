//
//  APIManager.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import "APIManager.h"

@implementation APIManager

static NSString * const KEYS_PATH = @"Keys";
static NSString * const KEYS_PATH_FILE_TYPE = @"plist";
static NSString * const SPOTIFY_CLIENT_ID_KEY = @"spotify_client_id";
static NSString * const SPOTIFY_CLIENT_SECRET_KEY = @"spotify_client_secret";

static NSString * const SPOTIFY_ACCOUNTS_URL_STRING = @"https://accounts.spotify.com/api/token?grant_type=client_credentials";
static NSString * const SPOTIFY_TOKEN_REQUEST_CONTENT_TYPE = @"application/x-www-form-urlencoded";
static NSString * const SPOTIFY_ACCESS_TOKEN_KEY = @"access_token";
static NSString * const SPOTIFY_GENRE_SEEDS_URL_STRING = @"https://api.spotify.com/v1/recommendations/available-genre-seeds";
static NSString * const SPOTIFY_GENRES_KEY = @"genres";

static NSString * const THE_AUDIO_DB_JSON_URL_STRING = @"https://theaudiodb.com/api/v1/json/1/search.php?s=%@";

+ (NSString *)base64URLSafeEncode:(NSString *)originalString {
    NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [originalData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"=" withString:@""];
    
    return base64String;
}

+ (void)generateSpotifyToken:(void(^)(NSString *_Nullable spotifyToken, NSError *_Nullable error))completion {
    NSString *path = [[NSBundle mainBundle] pathForResource: KEYS_PATH ofType: KEYS_PATH_FILE_TYPE];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *clientId = [dict objectForKey: SPOTIFY_CLIENT_ID_KEY];
    NSString *clientSecret = [dict objectForKey: SPOTIFY_CLIENT_SECRET_KEY];
    
    NSString *originalAuth = [NSString stringWithFormat:@"%@:%@", clientId, clientSecret];
    NSString *base64Auth = [APIManager base64URLSafeEncode:originalAuth];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", base64Auth];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:SPOTIFY_ACCOUNTS_URL_STRING]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    NSDictionary *headers = @{
        @"Authorization": authHeader,
        @"Content-Type": SPOTIFY_TOKEN_REQUEST_CONTENT_TYPE
    };
    
    [request setAllHTTPHeaderFields:headers];
    
    [request setHTTPMethod:@"POST"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSString *accessToken = responseDictionary[SPOTIFY_ACCESS_TOKEN_KEY];
            completion(accessToken, nil);
        }
    }];
    [dataTask resume];
}

+ (void)fetchGenres:(void(^)(NSArray *_Nullable genres, NSError *_Nullable error))completion {
    [APIManager generateSpotifyToken:^(NSString *_Nullable spotifyToken, NSError *error){
        if (spotifyToken) {
            NSURL *url = [NSURL URLWithString: SPOTIFY_GENRE_SEEDS_URL_STRING];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                               timeoutInterval:10.0];
            
            
            NSString *authHeader = [NSString stringWithFormat: @"Bearer %@", spotifyToken];
            NSDictionary *headers = @{
                @"Authorization": authHeader
            };
            
            [request setAllHTTPHeaderFields:headers];
            
            [request setHTTPMethod:@"GET"];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^() {
                        // call completion block on main
                        completion(nil, error);
                    });
                } else {
                    NSError *parseError = nil;
                    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                    
                    NSArray *genresArray = responseDictionary[ SPOTIFY_GENRES_KEY ];
                    dispatch_async(dispatch_get_main_queue(), ^() {
                        // call completion block on main
                        completion(genresArray, nil);
                    });
                }
            }];
            [dataTask resume];
        }
    }];
}

@end
