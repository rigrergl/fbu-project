//
//  SettingsViewController.m
//  fbu-project
//
//  Created by Rigre Reinier Garciandia Larquin on 7/21/21.
//

#import "SettingsViewController.h"
#import "MessagePoller.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (IBAction)pollLockSwitchValueChanged:(UISwitch *)sender {
    [MessagePoller shared].pollingLock = sender.on;
}


@end
