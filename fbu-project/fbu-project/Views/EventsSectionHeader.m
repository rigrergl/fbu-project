//
//  EventsSectionHeader.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/26/21.
//

#import "EventsSectionHeader.h"

@interface EventsSectionHeader ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation EventsSectionHeader

NSString * const EVENTS_SECTION_HEADER_REUSE_IDENTIFIER = @"EventsSectionHeader";

- (void)setTitle:(NSString *_Nonnull)title {
    self.titleLabel.text = title;
}

@end
