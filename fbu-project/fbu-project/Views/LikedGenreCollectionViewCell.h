//
//  LikedGenreCollectionViewCell.h
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import <UIKit/UIKit.h>
#import "LikedGenre.h"

NS_ASSUME_NONNULL_BEGIN

@interface LikedGenreCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (assign, nonatomic) BOOL canRemove;
@property (copy, nonatomic) void (^removeLikedGenre)(LikedGenreCollectionViewCell *_Nonnull cell);

- (void)setCellWithTitle:(NSString *)likedGenreTitle
               canRemove:(BOOL)canRemove;

@end

NS_ASSUME_NONNULL_END
