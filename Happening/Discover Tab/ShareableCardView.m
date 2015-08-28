//
//  ShareableCardView.m
//  Happening
//
//  Created by Max on 8/3/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ShareableCardView.h"
#import "CategoryBubbleView.h"

@implementation ShareableCardView {
    
    UIView *cardContainerView;
    float originalHeight;
    float originalWidth;
    UIButton *ticketsButton;

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

- (void)addExtras {
    
    float heightRatio = self.frame.size.height / 390;
    float widthRatio = self.frame.size.width / 284;
    float yRatio = heightRatio;
    float xRatio = widthRatio;
    
    //[self arrangeCornerViews];
    //[self loadCardWithData];
    
    ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 360.5 - 62, 100, 25)];
    ticketsButton.userInteractionEnabled = NO;
    
    ticketsButton.enabled = YES;
    ticketsButton.userInteractionEnabled = YES;
    ticketsButton.tag = 123;
    UIColor *hapBlue = [UIColor colorWithRed:0.0 green:185.0/255 blue:245.0/255 alpha:1.0];
    [ticketsButton setTitle:@"GET TICKETS" forState:UIControlStateNormal];
    //[ticketsButton setTitleColor:hapBlue forState:UIControlStateNormal];
    //[ticketsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [ticketsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ticketsButton setTitleColor:hapBlue forState:UIControlStateHighlighted];
    [ticketsButton setBackgroundColor:hapBlue];
    
    ticketsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0];
    
    ticketsButton.layer.masksToBounds = YES;
    ticketsButton.layer.borderColor = hapBlue.CGColor;
    ticketsButton.layer.borderWidth = 1.0;
    ticketsButton.layer.cornerRadius = 28/2;
    
    NSNumber *lowPriceNumber = self.eventObject[@"lowest_price"];
    if (![lowPriceNumber isKindOfClass:[NSNull class]] && lowPriceNumber != nil) {
        self.startPriceNumLabel.text = [NSString stringWithFormat:@"$%d", [lowPriceNumber intValue]];
    } else {
        self.startPriceNumLabel.text = @"";
    }
    [self.cardView addSubview:ticketsButton];
    
    NSString *ticketLink = self.eventObject[@"TicketLink"];
    int height = 0;
    
    if (ticketLink != nil && (![ticketLink isEqualToString:@""] || ![ticketLink isEqualToString:@"$0"])) {
        
        height += 20;
        
        ticketsButton.frame = CGRectMake((284-120)/2, 360.5 - 62, 120, 28);
        
        if ([self doesString:ticketLink contain:@"seatgeek.com"]) {
            
            if (![self.startPriceNumLabel.text isEqualToString:@""] && ![self.startPriceNumLabel.text isEqualToString:@"$0"] && self.startPriceNumLabel.text != nil) {
                
                NSString *startingString = [NSString stringWithFormat:@"GET TICKETS - STARTING AT %@", self.startPriceNumLabel.text];
                [ticketsButton setTitle:startingString forState:UIControlStateNormal];
                ticketsButton.frame = CGRectMake((284-230)/2, 360.5 - 62, 230, 28);
                
                /*
                 startPriceNumLabel = [[UILabel alloc] init];
                 startPriceNumLabel.textAlignment = NSTextAlignmentCenter;
                 startPriceNumLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13.0];
                 startPriceNumLabel.textColor = [UIColor grayColor];
                 //startPriceNumLabel.text = @"Starting";
                 startPriceNumLabel.tag = 3;
                 startPriceNumLabel.alpha = 0;
                 [cardView addSubview:startPriceNumLabel];
                 
                 
                 avePriceNumLabel = [[UILabel alloc] init];
                 avePriceNumLabel.textAlignment = NSTextAlignmentCenter;
                 avePriceNumLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13.0];
                 avePriceNumLabel.textColor = [UIColor grayColor];
                 //avePriceNumLabel.text = @"Avg";
                 avePriceNumLabel.tag = 3;
                 avePriceNumLabel.alpha = 0;
                 [cardView addSubview:avePriceNumLabel];
                 
                 UILabel *startingPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 349 + extraDescHeight - 62, 100, 30)];
                 startingPriceLabel.textAlignment = NSTextAlignmentCenter;
                 startingPriceLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12.0];
                 startingPriceLabel.textColor = [UIColor darkGrayColor];
                 startingPriceLabel.text = @"Starting";
                 [startingPriceLabel sizeToFit];
                 startingPriceLabel.center = CGPointMake(ticketsButton.center.x + 85 , ticketsButton.center.y);
                 startingPriceLabel.tag = 3;
                 [card.cardView addSubview:startingPriceLabel];
                 
                 startPriceNumLabel.frame = CGRectMake(startingPriceLabel.frame.size.width + startingPriceLabel.frame.origin.x + 5, startingPriceLabel.frame.origin.y, 50, 30);
                 [startPriceNumLabel sizeToFit];
                 startPriceNumLabel.center = CGPointMake(startPriceNumLabel.center.x, startingPriceLabel.center.y);
                 [card.cardView addSubview:startPriceNumLabel];
                 
                 if (![avePriceNumLabel.text isEqualToString:@""] && ![avePriceNumLabel.text isEqualToString:@"$0"]) {
                 
                 UILabel *avgPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(startPriceNumLabel.frame.origin.x + startPriceNumLabel.frame.size.width + 10, 349 + extraDescHeight - 62, 100, 30)];
                 avgPriceLabel.textAlignment = NSTextAlignmentCenter;
                 avgPriceLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12.0];
                 avgPriceLabel.textColor = [UIColor darkGrayColor];
                 avgPriceLabel.text = @"Avg";
                 [avgPriceLabel sizeToFit];
                 avgPriceLabel.center = CGPointMake(avgPriceLabel.center.x , ticketsButton.center.y);
                 avgPriceLabel.tag = 3;
                 [card.cardView addSubview:avgPriceLabel];
                 
                 avePriceNumLabel.frame = CGRectMake(avgPriceLabel.frame.size.width + avgPriceLabel.frame.origin.x + 5, avgPriceLabel.frame.origin.y, 50, 30);
                 [avePriceNumLabel sizeToFit];
                 avePriceNumLabel.center = CGPointMake(avePriceNumLabel.center.x, avgPriceLabel.center.y);
                 [card.cardView addSubview:avePriceNumLabel];
                 
                 } */
            }
            
        } else if ([self doesString:ticketLink contain:@"facebook.com"]) {
            
            [ticketsButton setTitle:@"RSVP TO FACEBOOK EVENT" forState:UIControlStateNormal];
            ticketsButton.frame = CGRectMake(15, 360.5 - 62, 200, 25);
            ticketsButton.center = CGPointMake(self.center.x, ticketsButton.center.y);
            
        } else if ([self doesString:ticketLink contain:@"meetup.com"]) {
            
            [ticketsButton setTitle:@"RSVP ON MEETUP.COM" forState:UIControlStateNormal];
            ticketsButton.frame = CGRectMake(15, 360.5 - 62, 200, 25);
            ticketsButton.center = CGPointMake(self.center.x, ticketsButton.center.y);
            
        } else if ([[self.eventObject objectForKey:@"isFreeEvent"] isEqualToNumber:@YES]) {
            
            [ticketsButton setTitle:@"THIS EVENT IS FREE!" forState:UIControlStateNormal];
            ticketsButton.frame = CGRectMake(15, 360.5 - 62, 200, 25);
            ticketsButton.center = CGPointMake(self.center.x, ticketsButton.center.y);
            
        }
        
    } else { //no tix
        /*
        UILabel *noTixLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 360.5 - 62, 250, 25)];
        noTixLabel.textAlignment = NSTextAlignmentCenter;
        noTixLabel.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:12.0];
        noTixLabel.textColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0];
        noTixLabel.tag = 123;
        
        if ([[self.eventObject objectForKey:@"isTicketedEvent"] isEqualToNumber:@NO]) {
            noTixLabel.text = @"This event does not have tickets.";
        } else if ([[self.eventObject objectForKey:@"isFreeEvent"] isEqualToNumber:@YES]){
            noTixLabel.text = @"This event is free! No tickets required.";
        } else if ([[self.eventObject objectForKey:@"private"] isEqualToNumber:@YES]) {
            
        } else {
            /*
            noTixLabel.text = @"No ticket information is available."; */
           // noTixLabel.text = @"";
        //}*/
        
        [ticketsButton removeFromSuperview];
        /*
        noTixLabel.center = CGPointMake(self.cardView.center.x, noTixLabel.center.y);
        [self.cardView addSubview:noTixLabel];
        */
    }

    ticketsButton.titleLabel.font = [ticketsButton.titleLabel.font fontWithSize: ticketsButton.titleLabel.font.pointSize * (heightRatio*1.6)];
    /*
    if (self.eventObject[@"Hashtag"]) {
        self.hashtag.text = [NSString stringWithFormat:@"%@", self.eventObject[@"Hashtag"]];
        CategoryBubbleView *catView  = [[CategoryBubbleView alloc] initWithText:self.eventObject[@"Hashtag"] type:@"normal"];
        [self.cardView addSubview:catView];
    } else {
        self.hashtag.text = @"";
    }*/
    
    for (UIView *view in self.cardView.subviews) {
        
        if (view.tag == 123) {
        
            CGRect viewRect = view.frame;
            viewRect.origin.y = viewRect.origin.y * yRatio;
            viewRect.origin.x = viewRect.origin.x * xRatio;
            viewRect.size.height = viewRect.size.height * heightRatio;
            view.frame = viewRect;
            
            if ([view isKindOfClass:[CategoryBubbleView class]]) {
                
                CategoryBubbleView *bubbleView = (CategoryBubbleView *)view;
                bubbleView.textLabel.font = [bubbleView.textLabel.font fontWithSize: bubbleView.textLabel.font.pointSize * (heightRatio*1.8)];
                bubbleView.layer.cornerRadius = bubbleView.frame.size.height / 2;
                viewRect.size.width = bubbleView.frame.size.width - viewRect.origin.x*1.9;
                
                CGRect viewRect = bubbleView.textLabel.frame;
                viewRect.origin.y = viewRect.origin.y * yRatio;
                viewRect.origin.x = viewRect.origin.x * xRatio;
                viewRect.size.height = viewRect.size.height * heightRatio;
                viewRect.size.width = viewRect.size.width - viewRect.origin.x*2.0;  //viewRect.size.width * widthRatio;
                bubbleView.textLabel.frame = viewRect;
                
            } else {
                
                viewRect.size.width = self.frame.size.width - viewRect.origin.x*2;  //viewRect.size.width * widthRatio;

            }
            
            view.frame = viewRect;
            
        }
    }
    
    ticketsButton.layer.cornerRadius = ticketsButton.frame.size.height / 2;
    CGRect ticketsFrame = ticketsButton.frame;
    ticketsFrame.origin.y += 15;
    ticketsButton.frame = ticketsFrame;
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
                label.font = [label.font fontWithSize: label.font.pointSize * (heightRatio*2.1)];
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
        
        
        ticketsButton.titleLabel.font = [ticketsButton.titleLabel.font fontWithSize: ticketsButton.titleLabel.font.pointSize * (heightRatio*2.5)];
        
        for (UIView *view in self.cardView.subviews) {
            
            if (view.tag == 123) {
                
                CGRect viewRect = view.frame;
                
                //viewRect.size.height += viewRect.size.height * heightRatio;
                //viewRect.size.width = self.frame.size.width - viewRect.origin.x*2;  //viewRect.size.width * widthRatio;
                
                view.frame = viewRect;
                
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    label.font = [label.font fontWithSize: label.font.pointSize * (heightRatio*2.1)];
                    //label set = label.font.pointSize * fontSizeRatio;
                }
                
                if ([view isKindOfClass:[CategoryBubbleView class]]) {
                    
                    CategoryBubbleView *bubbleView = (CategoryBubbleView *)view;
                    bubbleView.textLabel.font = [bubbleView.textLabel.font fontWithSize: bubbleView.textLabel.font.pointSize * (heightRatio*2.5)];
                    bubbleView.layer.cornerRadius = bubbleView.frame.size.height / 2;
                    viewRect.size.width = bubbleView.frame.size.width - viewRect.origin.x*1.6;
                    viewRect.size.height += 10;

                    
                    CGRect newRect = bubbleView.textLabel.frame;
                    newRect.origin.y += newRect.origin.y * yRatio;
                    newRect.origin.x += newRect.origin.x * xRatio;
                    newRect.size.height += viewRect.size.height;
                    newRect.size.width = viewRect.size.width - 3;  //viewRect.size.width * widthRatio;
                    
                    bubbleView.textLabel.frame = newRect;
                    
                } else {
                    
                    //viewRect.size.width = self.frame.size.width - viewRect.origin.x*2;  //viewRect.size.width * widthRatio;
                    
                }
                
                view.frame = viewRect;
                
            }
        }
        
        CGRect tFrame = ticketsButton.frame;
        ticketsButton.frame = CGRectMake(ticketsButton.center.x - (tFrame.size.width * 1.3) / 2, tFrame.origin.y + 8, tFrame.size.width * 1.3, tFrame.size.height * 2);
        ticketsButton.layer.cornerRadius = ticketsButton.frame.size.height / 2;
        //CGRect ticketsFrame = ticketsButton.frame;
        //ticketsFrame.origin.y += -30;
        //ticketsButton.frame = ticketsFrame;
        
        
        self.eventImage.image = self.cachedImage;
        
    } completion:^(BOOL finished) {
        
        UIView *downloadHappeningView = [[UIView alloc] initWithFrame: CGRectMake(10, 10, 165, 20)];  //CGRectMake(8, 8, self.frame.size.width - 16, 20)];
        downloadHappeningView.backgroundColor = [UIColor colorWithRed:0 green:172.0/255 blue:242.0/255 alpha:1.0];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:downloadHappeningView.bounds];
        textLabel.text = @"Happening - Events with Friends"; //@"  Download Happening at http://happening.city/app  ";
        textLabel.font = [UIFont fontWithName:@"OpenSans" size:10.0];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        //[textLabel sizeToFit];
        
        downloadHappeningView.layer.cornerRadius = 10;
        downloadHappeningView.layer.masksToBounds = YES;
        [downloadHappeningView addSubview:textLabel];
        
        [self addSubview:downloadHappeningView];
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self.shareDelegate setupSuperviewForImageCapture];
        UIImage *image = [ShareableCardView imageWithView:self.superview];
        
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
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

-(BOOL)doesString:(NSString *)first contain:(NSString*)other {
    NSRange range = [first rangeOfString:other];
    return range.length != 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
