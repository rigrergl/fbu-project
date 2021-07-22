//
//  EventCollectionViewCell.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "EventCollectionViewCell.h"

@interface EventCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation EventCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setRoundedCorners];
}

- (void)setCell:(Event *_Nonnull)event {
    self.event = event;
    self.titleLabel.text = event.title;
    self.dateLabel.text = [EventCollectionViewCell getDateString:event.date];
}

+ (NSString *)getDateString:(NSDate *_Nonnull)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MMM-dd"];
    
    return [dateFormatter stringFromDate:date];
}

-  (void)setRoundedCorners {
    static const float CELL_CORNER_RADIUS = 14;
    self.layer.cornerRadius = CELL_CORNER_RADIUS;
    self.layer.masksToBounds = YES;
}

- (IBAction)didTapInfoButton:(UIButton *)sender {
    if (self.segueToInfo) {
        self.segueToInfo(self);
    }
}

- (IBAction)didTapChatButton:(UIButton *)sender {
    if (self.segueToChat) {
        self.segueToChat(self);
    }
}

- (IBAction)didTapAccept:(UIButton *)sender {
    if (self.acceptInvite) {
        self.acceptInvite(self);
    }
}

@end
