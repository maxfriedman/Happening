//
//  ShareableCardView.m
//  Happening
//
//  Created by Max on 8/3/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ShareableCardView.h"

@implementation ShareableCardView {
    
    UIView *cardContainerView;
    float originalHeight;
    float originalWidth;

}

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    originalHeight = frame.size.height;
    originalWidth = frame.size.width;
    
    if (!self) {
    
        // Doesnt get called..  because I subclassed DraggableView??
    }
    
    self.cardView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    self.isSwipeable = NO;
    
    float heightRatio = frame.size.height / 390;
    float widthRatio = frame.size.width / 284;
    
    float yRatio = heightRatio;
    float xRatio = widthRatio;
    
    float fontSizeRatio = heightRatio;
    
    //self = (ShareableCardView *)[[DraggableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.width)];
    
    
    for (UIView *view in self.cardView.subviews) {
        
        CGRect viewRect = view.frame;
        
        viewRect.origin.y = viewRect.origin.y * yRatio;
        viewRect.origin.x = viewRect.origin.x * xRatio;
        
        viewRect.size.height = viewRect.size.height * heightRatio;
        viewRect.size.width = frame.size.width - viewRect.origin.x*2;  //viewRect.size.width * widthRatio;
        
        view.frame = viewRect;
        
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.font = [label.font fontWithSize: label.font.pointSize * (heightRatio*1.8)];
            //label set = label.font.pointSize * fontSizeRatio;
        }
    }
    
    CGRect dateFrame = self.date.frame;
    dateFrame.origin.y += 5;
    self.date.frame = dateFrame;
    
    
    CGRect titleFrame = self.title.frame;
    titleFrame.origin.y += -5;
    self.title.frame = titleFrame;
    
    self.cardView.layer.borderColor = [UIColor colorWithRed:0 green:185.0/255 blue:245.0/255 alpha:1.0].CGColor;
    self.eventImage.layer.borderColor = [UIColor colorWithRed:0 green:185.0/255 blue:245.0/255 alpha:1.0].CGColor;
    
    
    return self;
}

- (void)zoomCard {
    
    CGFloat s = 1.8;
    CGAffineTransform tr = CGAffineTransformScale(self.transform, s, s);
    
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{  //animateWithDuration:0.7 delay:0 options:0 animations:^{
        //self.center = CGPointMake(w-w*s/2,h*s/2);
        //self.transform = tr;
        
        self.frame = CGRectMake(self.frame.origin.x - 50, self.frame.origin.y - 50, self.frame.size.width + 100, self.frame.size.height + 100);
        self.cardView.frame = self.bounds;
        
        float heightRatio = originalHeight/self.frame.size.height;   //frame.size.height / 390;
        float widthRatio =  originalWidth/self.frame.size.width;   //frame.size.width / 284;
        
        float yRatio = heightRatio;
        float xRatio = widthRatio;
        
        for (UIView *view in self.cardView.subviews) {
            
            CGRect viewRect = view.frame;
            
            viewRect.origin.y += viewRect.origin.y * yRatio;
            viewRect.origin.x += viewRect.origin.x * xRatio;
            
            //viewRect.size.height += viewRect.size.height * heightRatio;
            viewRect.size.width = self.frame.size.width - viewRect.origin.x*2;  //viewRect.size.width * widthRatio;
            
            view.frame = viewRect;
            
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                label.font = [label.font fontWithSize: label.font.pointSize * (heightRatio*2.5)];
                //label set = label.font.pointSize * fontSizeRatio;
            }
        }
        
        
        CGRect titleFrame = self.title.frame;
        titleFrame.origin.y += 20;
        self.title.frame = titleFrame;
        
        CGRect locFrame = self.location.frame;
        locFrame.origin.y += 20;
        self.location.frame = locFrame;
        
        CGRect dateFrame = self.date.frame;
        dateFrame.origin.y += 20;
        self.date.frame = dateFrame;
        
        self.eventImage.image = self.cachedImage;
        
    } completion:^(BOOL finished) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImage *image = [ShareableCardView imageWithView:self];
        
        [self.shareDelegate cardImageGenerated: image];
        
    }];
}

- (UILabel *)deepLabelCopy:(UILabel *)label {
    
    UILabel *duplicateLabel = [[UILabel alloc] initWithFrame:CGRectIntegral(label.frame)];
    duplicateLabel.text = label.text;
    duplicateLabel.textColor = label.textColor;
    
    duplicateLabel.font = label.font; //[label.font fontWithSize:(int)label.font.pointSize];
    duplicateLabel.textAlignment = label.textAlignment;
    
    return duplicateLabel;
}

+ (UIImage *) imageWithView:(UIView *)view
{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
