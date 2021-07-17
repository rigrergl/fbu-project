//
//  FavoriteArtist.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import "FavoriteArtist.h"

static NSString *resultArrayKey = @"artists";

@implementation FavoriteArtist

+ (NSString *)parseClassName {
    return @"FavoriteArtist";
}

- (id)initWithDictionary:(NSDictionary *_Nonnull)dictionary
                   andId:(NSString *)artistId {
    if (!dictionary) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        self.artistId = artistId;
        NSArray *artistArray = dictionary[resultArrayKey];
        if (artistArray == [NSNull null]) {
            return nil;
        }

        NSDictionary *artistDictionary = artistArray[0];
        self.user = [PFUser currentUser];
    }
    
    return self;
}

@end
