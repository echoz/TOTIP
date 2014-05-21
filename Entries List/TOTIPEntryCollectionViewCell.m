//
//  TOTIPEntryCollectionViewCell.m
//  TOTIP
//
//  Created by Jeremy Foo on 21/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPEntryCollectionViewCell.h"

@implementation TOTIPEntryCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _contentInset = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        
        _titleBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _titleBackgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.950];
        [self.contentView addSubview:_titleBackgroundView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.numberOfLines = 1;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        detailLabel.numberOfLines = 1;
        detailLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        detailLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.000];
        [self.contentView addSubview:detailLabel];
        _detailLabel = detailLabel;
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, frame.size}];
        backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        backgroundView.clipsToBounds = YES;
        self.backgroundView = backgroundView;
        _imageView = backgroundView;
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundView.alpha = (highlighted) ? 0.25f : 1.0f;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.titleBackgroundView.superview != self.contentView) [self.contentView insertSubview:self.titleBackgroundView atIndex:0];
    self.titleBackgroundView.frame = CGRectMake(0, self.contentInset.top - self.contentInset.bottom, self.bounds.size.width, self.bounds.size.height - self.contentInset.top + self.contentInset.bottom);
    
    [self.titleLabel sizeToFit];
    [self.detailLabel sizeToFit];
    
    self.titleLabel.frame = CGRectMake(self.contentInset.left,
                                       self.contentInset.top + self.contentInset.bottom,
                                       self.bounds.size.width - self.contentInset.left - self.contentInset.right,
                                       self.titleLabel.bounds.size.height);
    
    self.detailLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame),
                                        CGRectGetMaxY(self.titleLabel.frame),
                                        CGRectGetWidth(self.titleLabel.frame),
                                        self.detailLabel.bounds.size.height);
    
}

@end
