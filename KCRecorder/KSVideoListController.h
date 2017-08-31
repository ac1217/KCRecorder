//
//  KSVideoListController.h
//  KCRecorder
//
//  Created by iMac on 2017/8/31.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KCRecorderItem.h"

@interface KSVideoListController : UITableViewController
@property (nonatomic,strong) NSArray <KCRecorderItem *>*items;
@end
