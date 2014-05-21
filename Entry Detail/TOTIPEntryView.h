//
//  TOTIPEntryView.h
//  TOTIP
//
//  Created by Jeremy Foo on 21/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOTIPEntryView : UIView

@property (nonatomic, weak, readonly) UIImageView *imageView;

@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, weak, readonly) UILabel *byLineLabel;

@property (nonatomic, weak, readonly) UILabel *summaryLabel;
@property (nonatomic, weak, readonly) UILabel *categoryLabel;

@property (nonatomic, weak, readonly) UILabel *releaseDateLabel;
@property (nonatomic, weak, readonly) UILabel *copyrightLabel;

@end
