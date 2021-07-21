//
//  EventCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "EventCollectionViewCell.h"

@implementation EventCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setRoundedCorners];
}

-  (void)setRoundedCorners {
    static const float CELL_CORNER_RADIUS = 14;
    self.layer.cornerRadius = CELL_CORNER_RADIUS;
    self.layer.masksToBounds = YES;
}

- (IBAction)didTapInfoButton:(UIButton *)sender {
   //TODO: segue to event info page
}

- (IBAction)didTapChatButton:(UIButton *)sender {
    //TODO: segue to event chat page
}

@end
