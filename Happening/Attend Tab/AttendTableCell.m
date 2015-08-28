//
//  AttendTableCell.m
//  Happening
//
//  Created by Max on 10/8/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "AttendTableCell.h"
#import "UIImage+ImageEffects.h"

@implementation AttendTableCell

@synthesize blurView;

- (void)awakeFromNib {
    
    //self.layer.masksToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.eventImageView.bounds;

    //[self.eventImageView addSubview:blurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.frame = blurEffectView.bounds;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.eventImageView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
    //[self.eventImageView.layer insertSublayer:gradient atIndex:0];
    //[blurEffectView.layer insertSublayer:gradient atIndex:2];
    /*
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = self.eventImageView.bounds;
    l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    l.startPoint = CGPointMake(0.0, 1.00f);
    l.endPoint = CGPointMake(0.0f, 0.0f);
    */
    
    //[blurView setUpdateInterval:0.1];
    //blurView.dynamic = NO;
    //blurView.blurRadius = 30; //14
    //blurView.tintColor = [UIColor blackColor];
    //blurView.dynamic = NO;
    //[self.eventImageView addSubview:blurView];
    
    self.eventImageView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.eventImageView.layer.borderWidth = 2.0;
    
    ////self.eventImageView.alpha = 0.97;
    
    [self.eventImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.eventImageView.autoresizingMask =
    ( UIViewAutoresizingFlexibleBottomMargin
     | UIViewAutoresizingFlexibleHeight
     | UIViewAutoresizingFlexibleLeftMargin
     | UIViewAutoresizingFlexibleRightMargin
     | UIViewAutoresizingFlexibleTopMargin
     | UIViewAutoresizingFlexibleWidth );
    
    
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    
    // Hoizontal - commenting these two lines will make the gradient veritcal
    //maskLayer.startPoint = CGPointMake(0.0, 0.5);
    //maskLayer.endPoint = CGPointMake(1.0, 0.5);
    //maskLayer.startPoint = CGPointMake(0.0, 0.5);
    //maskLayer.endPoint = CGPointMake(1.0, 0.5);
    
    //maskLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.3].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor, nil];
    
    maskLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:0.8].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.6].CGColor, /*(id)[UIColor colorWithWhite:1.0 alpha:0.7].CGColor,*/ (id)[UIColor colorWithWhite:1.0 alpha:0.8].CGColor, nil];
    
    //l.startPoint = CGPointMake(0.0, 0.7f);
    //l.endPoint = CGPointMake(0.0f, 1.0f);
    maskLayer.locations = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.55],
                           //[NSNumber numberWithFloat:0.7],
                           //[NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:1.0], nil];
    
    maskLayer.bounds = self.eventImageView.bounds;
    maskLayer.anchorPoint = CGPointZero;
    [self.eventImageView.layer addSublayer:maskLayer];
    
    self.locLabel.textColor = [UIColor whiteColor];

    
    //self.eventImageView.layer.mask = l;
    //blurEffectView.layer.mask = l;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    UIView *whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(18,5,284,138)];
    whiteRoundedCornerView.backgroundColor = [UIColor whiteColor];
    whiteRoundedCornerView.layer.masksToBounds = YES;
    whiteRoundedCornerView.layer.cornerRadius = 10.0;
    whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
    whiteRoundedCornerView.layer.shadowOpacity = 1.0;
    whiteRoundedCornerView.layer.borderColor = [UIColor lightGrayColor].CGColor;

    whiteRoundedCornerView.layer.borderWidth = 1.0;
    
    [self.contentView addSubview:whiteRoundedCornerView];
    [whiteRoundedCornerView addSubview:self.eventImageView];
    //[self.eventImageView addSubview:blurView];
    //[whiteRoundedCornerView addSubview:blurView];
    
    UIView *internalShadowView = [[UIView alloc] initWithFrame:CGRectMake(0,135.5,284,2)];
    internalShadowView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //internalShadowView.alpha = 0.8;
    //[whiteRoundedCornerView addSubview:internalShadowView];
    

    UIView *externalShadowView = [[UIView alloc] initWithFrame:CGRectMake(19,135,282,10)];
    externalShadowView.layer.cornerRadius = 8.0;
    externalShadowView.backgroundColor = [UIColor lightGrayColor];
    externalShadowView.alpha = 0.3;
    //[self.contentView addSubview:externalShadowView];
    
    CGRect lineViewFrame = self.lineView.frame;
    //lineViewFrame.origin.x += 0.5;
    self.lineView.frame = lineViewFrame;
    
    [self.contentView sendSubviewToBack:whiteRoundedCornerView];
    
    
    [self.contentView sendSubviewToBack:externalShadowView];
    
    /*
    self.layer.borderWidth = 20.0;
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    
    self.layer.masksToBounds = YES;
*/
    
}

- (void)setupCell {
    
    
}

- (void)setFrame:(CGRect)frame {
    
    //int inset = 10;
    
    //frame.origin.x += inset;
    //frame.size.width -= 2 * inset;
    [super setFrame:frame];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(NewsUITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (cell.IsMonth)
    {
        UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 20, 20)];
        av.backgroundColor = [UIColor clearColor];
        av.opaque = NO;
        av.image = [UIImage imageNamed:@"month-bar-bkgd.png"];
        UILabel *monthTextLabel = [[UILabel alloc] init];
        CGFloat font = 11.0f;
        monthTextLabel.font = [BVFont HelveticaNeue:&font];
        
        cell.backgroundView = av;
        cell.textLabel.font = [BVFont HelveticaNeue:&font];
        cell.textLabel.textColor = [BVFont WebGrey];
    }
    
    
    if (indexPath.row != 0)
    {
        cell.contentView.backgroundColor = [UIColor clearColor];
        UIView *whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(10,10,300,70)];
        whiteRoundedCornerView.backgroundColor = [UIColor whiteColor];
        whiteRoundedCornerView.layer.masksToBounds = NO;
        whiteRoundedCornerView.layer.cornerRadius = 3.0;
        whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
        whiteRoundedCornerView.layer.shadowOpacity = 0.5;
        [cell.contentView addSubview:whiteRoundedCornerView];
        [cell.contentView sendSubviewToBack:whiteRoundedCornerView];
        
    }
}
 */


@end
