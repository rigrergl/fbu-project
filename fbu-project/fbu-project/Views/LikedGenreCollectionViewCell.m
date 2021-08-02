//
//  LikedGenreCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import "LikedGenreCollectionViewCell.h"
#import "CommonFunctions.h"

@implementation LikedGenreCollectionViewCell

- (void)setCellWithTitle:(NSString *_Nonnull)likedGenreTitle
               canRemove:(BOOL)canRemove {
    self.canRemove = canRemove;
    if (canRemove) {
        enableButton(self.removeButton);
    } else {
        disableButton(self.removeButton);
    }
    
    self.titleLabel.text = likedGenreTitle;
}

- (IBAction)didTapRemoveButton:(UIButton *)sender {
    if (!self.canRemove) {
        return;
    } else if (self.removeLikedEntity) {
        self.removeLikedEntity(self);
    }
}

@end
