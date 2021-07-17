//
//  FavoriteArtist.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/16/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface FavoriteArtist : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *artistId;
@property (nonatomic, strong) PFUser *user;

- (id)initWithDictionary:(NSDictionary *_Nonnull)dictionary
                   andId:(NSString *)artistId;

@end

NS_ASSUME_NONNULL_END
