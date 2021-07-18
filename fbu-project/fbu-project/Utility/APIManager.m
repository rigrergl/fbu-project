//
//  APIManager.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import "APIManager.h"

@implementation APIManager

+ (NSString *)base64URLSafeEncode:(NSString *)originalString {
    NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [originalData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    base64String = [base64String stringByReplacingOccurrencesOfString:@"=" withString:@""];
    
    return base64String;
}

+ (void)generateSpotifyToken:(void(^)(NSString *_Nullable spotifyToken, NSError *_Nullable error))completion {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *clientId = [dict objectForKey: @"spotify_client_id"];
    NSString *clientSecret = [dict objectForKey: @"spotify_client_secret"];
    
    NSString *originalAuth = [NSString stringWithFormat:@"%@:%@", clientId, clientSecret];
    NSString *base64Auth = [APIManager base64URLSafeEncode:originalAuth];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", base64Auth];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://accounts.spotify.com/api/token?grant_type=client_credentials"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    NSDictionary *headers = @{
        @"Authorization": authHeader,
        @"Content-Type": @"application/x-www-form-urlencoded"
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
            NSString *accessToken = responseDictionary[@"access_token"];
            completion(accessToken, nil);
        }
    }];
    [dataTask resume];
}

+ (void)fetchGenres:(void(^)(NSArray *_Nullable genres, NSError *_Nullable error))completion {
    [APIManager generateSpotifyToken:^(NSString *_Nullable spotifyToken, NSError *error){
        if (spotifyToken) {
            NSURL *url = [NSURL URLWithString:@"https://api.spotify.com/v1/recommendations/available-genre-seeds"];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                               timeoutInterval:10.0];
            
            
            NSString *authHeader = [NSString stringWithFormat:@"Bearer %@", spotifyToken];
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
                    
                    NSArray *genresArray = responseDictionary[@"genres"];
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

+ (void)fetchArtist:(NSString *)artistId
     withCompletion:(void(^)(NSDictionary *_Nullable responseDictionary,NSError *_Nullable error))completion {
    NSString *urlString = [NSString stringWithFormat:@"https://theaudiodb.com/api/v1/json/1/search.php?s=%@", artistId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            dispatch_async(dispatch_get_main_queue(), ^() {
                // call completion block on main
                completion(responseDictionary, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^() {
                // call completion block on main
                completion(nil, error);
            });
        }
    }];
    [task resume];
}

+ (NSString *)formatArtistName:(NSString *)artistName {
    NSString *lowercaseString = [artistName lowercaseString];
    NSArray *words = [lowercaseString componentsSeparatedByString: @" "];
    
    
    NSString *formattedString = @"";
    BOOL insertedFirstWord = NO;
    for (NSString *word in words) {
        if ([word length] > 0) {
            NSString *newWord;
            if (insertedFirstWord) {
                newWord = [NSString stringWithFormat:@"_%@", word];
            } else {
                newWord = word;
                insertedFirstWord = YES;
            }
            formattedString = [formattedString stringByAppendingString:newWord];
        }
    }
    
    return formattedString;
}

@end
