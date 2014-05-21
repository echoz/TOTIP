//
//  TOTIPEntryView.m
//  TOTIP
//
//  Created by Jeremy Foo on 21/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import "TOTIPEntryView.h"

@interface TOTIPEntryView ()
@property (nonatomic, weak, readonly) UIView *titleBackgroundView;

@end

@implementation TOTIPEntryView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, frame.size.width, frame.size.height * 0.5f}];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        _imageView = imageView;
        
        UIView *titleBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) - CGRectGetHeight(imageView.frame) * 0.4f, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame) * 0.4f)];
        titleBackgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.950];
        [self addSubview:titleBackgroundView];
        _titleBackgroundView = titleBackgroundView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
        titleLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        titleLabel.numberOfLines = 2;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UILabel *bylineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        bylineLabel.numberOfLines = 1;
        [self addSubview:bylineLabel];
        _byLineLabel = bylineLabel;
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        categoryLabel.numberOfLines = 1;
        categoryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        categoryLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0f];
        [self addSubview:categoryLabel];
        _categoryLabel = categoryLabel;
        
        UILabel *releaseDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        releaseDateLabel.numberOfLines = 1;
        releaseDateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        releaseDateLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
        [self addSubview:releaseDateLabel];
        _releaseDateLabel = releaseDateLabel;
        
        UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        summaryLabel.numberOfLines = 0;
        summaryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        summaryLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.000];
        [self addSubview:summaryLabel];
        _summaryLabel = summaryLabel;
        
        UILabel *copyrightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        copyrightLabel.numberOfLines = 0;
        copyrightLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        copyrightLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
        [self addSubview:copyrightLabel];
        _copyrightLabel = copyrightLabel;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = (CGRect){CGPointZero, self.bounds.size.width, self.bounds.size.height * 0.6f};

    [self.byLineLabel sizeToFit];
    self.byLineLabel.frame = CGRectMake(10.f, CGRectGetMaxY(self.imageView.frame) - 10.0f - self.byLineLabel.bounds.size.height, self.bounds.size.width - 20.0f, self.byLineLabel.bounds.size.height);

    CGSize textSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 20.0f, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName: self.titleLabel.font}
                                                         context:nil].size;

    self.titleLabel.frame = CGRectMake(10.0f, CGRectGetMinY(self.byLineLabel.frame) - textSize.height - 7.0f, textSize.width, textSize.height);

    self.titleBackgroundView.frame = CGRectMake(0, CGRectGetMinY(self.titleLabel.frame) - 10.0f, CGRectGetWidth(self.imageView.frame), CGRectGetHeight(self.imageView.frame) - (CGRectGetMinY(self.titleLabel.frame) - 10.0f));
    
    [self.categoryLabel sizeToFit];
    self.categoryLabel.frame = CGRectMake(CGRectGetMinX(self.titleLabel.frame), CGRectGetMaxY(self.titleBackgroundView.frame) + 10.0f, self.categoryLabel.bounds.size.width, self.categoryLabel.bounds.size.height);
    
    [self.releaseDateLabel sizeToFit];
    self.releaseDateLabel.frame = CGRectMake(self.bounds.size.width - 10.0f - self.releaseDateLabel.bounds.size.width, CGRectGetMaxY(self.categoryLabel.frame) - self.releaseDateLabel.bounds.size.height, self.releaseDateLabel.bounds.size.width, self.releaseDateLabel.bounds.size.height);
    
    CGSize summaryTextSize = [self.summaryLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 20.0f, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName: self.summaryLabel.font}
                                                                  context:nil].size;
    
    self.summaryLabel.frame = CGRectMake(CGRectGetMinX(self.categoryLabel.frame), CGRectGetMaxY(self.categoryLabel.frame) + 10.0f, summaryTextSize.width, summaryTextSize.height);
    
    CGSize copyrightTextSize = [self.copyrightLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 20.0f, CGFLOAT_MAX)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName: self.copyrightLabel.font}
                                                                      context:nil].size;
    
    self.copyrightLabel.frame = CGRectMake(CGRectGetMinX(self.summaryLabel.frame), CGRectGetMaxY(self.summaryLabel.frame) + 30.0f, copyrightTextSize.width, copyrightTextSize.height);
}

@end
