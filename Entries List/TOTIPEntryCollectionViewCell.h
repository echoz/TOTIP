//
//  TOTIPEntryCollectionViewCell.h
//  TOTIP
//
//  Created by Jeremy Foo on 21/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOTIPEntryCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, weak, readonly) UILabel *detailLabel;

@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, strong) UIView *titleBackgroundView;

@end
