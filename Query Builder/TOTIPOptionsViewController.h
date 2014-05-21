//
//  TOTIPOptionsViewController.h
//  TOTIP
//
//  Created by Jeremy Foo on 19/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TOTIPOptionsViewController;

@protocol TOTIPOptionsViewControllerDelegate <NSObject>
@required
-(void)optionsViewController:(TOTIPOptionsViewController *)optionsViewController didSelectKey:(id<NSCopying>)key value:(id)value;
@end

@interface TOTIPOptionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) id<TOTIPOptionsViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *sectionTitle;
@property (nonatomic, copy) NSString *helpText;

@property (nonatomic, copy) NSIndexPath *initialIndexPath;

@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, strong, readonly) NSArray *keys;
@property (nonatomic, copy, readonly) NSDictionary *keyValueMap;

-(instancetype)initWithKeyValueMap:(NSDictionary *)keyValue;

@end
