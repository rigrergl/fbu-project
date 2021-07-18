//
//  LikedGenreCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/18/21.
//

#import "LikedGenreCollectionViewCell.h"

@implementation LikedGenreCollectionViewCell


- (void)setCellWithTitle:(NSString *_Nonnull)likedGenreTitle canRemove:(BOOL)canRemove {
    self.canRemove = canRemove;
    if (canRemove) {
        [self enableRemoveButton];
    } else {
        [self disableRemoveButton];
    }
    
    self.titleLabel.text = likedGenreTitle;
}

- (void)disableRemoveButton {
    self.removeButton.enabled = NO;
    self.removeButton.alpha = 0;
}

- (void)enableRemoveButton {
    self.removeButton.enabled = YES;
    self.removeButton.alpha = 1;
}

- (IBAction)didTapRemoveButton:(UIButton *)sender {
    if (!self.canRemove) {
        return;
    } else if (self.removeLikedGenre) {
        self.removeLikedGenre(self);
    }
}

@end
