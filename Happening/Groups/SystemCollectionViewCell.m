//
//  SystemCollectionViewCell.m
//  Happening
//
//  Created by Max on 6/23/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "SystemCollectionViewCell.h"

@interface SystemCollectionViewCell ()

@property (strong,nonatomic) LYRMessage *message;
@property (strong,nonatomic) UILabel *messageLabel;

@end

@implementation SystemCollectionViewCell

@synthesize messageLabel;

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self)
    {
        
        NSLog(@"%f - %f", frame.size.height, frame.size.width);
        
        //UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height)];
        //backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        //[self addSubview:backgroundView];
        
        //self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self shouldDisplayAvatarItem:NO];
        
        messageLabel = [[UILabel alloc] init]; //WithFrame:CGRectMake(25, 0, 320-50, backgroundView.frame.size.height)];
        messageLabel.font = [UIFont fontWithName:@"OpenSans" size:10.0];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor darkTextColor];
        messageLabel.numberOfLines = 2;
        messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [messageLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:messageLabel];
        
        [self configureConstraints];
        
    }
    return self;
}

// I am not good with constraints at all- What I am looking for is a way to dynamically set contraints based on the height of the cell, which may be 1, 2, or 3 lines of text.
- (void)configureConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:ATLMessageBubbleLabelVerticalPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:ATLMessageBubbleLabelHorizontalPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-ATLMessageBubbleLabelHorizontalPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ATLMessageBubbleLabelVerticalPadding]];
}

- (void)buttonTapped:(id)sender {
    // Show message identifer in Alert Dialog
    NSString *alertText = self.message.identifier.description;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:alertText delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Ok"];
    [alert show];
}

- (void)presentMessage:(LYRMessage *)message {
    self.message = message;
    LYRMessagePart *part = message.parts[0];
    
    // if message contains custom mime type then get the text from the MessagePart JSON
    if([part.MIMEType isEqual: ATLMimeTypeSystemObject])
    {
        NSData *data = part.data;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        
        messageLabel.text = [json objectForKey:@"message"];
        
        NSString *type = [json objectForKey:@"type"];
        
        if ([type isEqualToString:@"leave"]) {
            
        } else if ([type isEqualToString:@"add"]) {
            
        } else if ([type isEqualToString:@"name"]) {
            
        } else if ([type isEqualToString:@"new"]) {
            
        }
        
    }
}

- (void)updateWithSender:(id<ATLParticipant>)sender{
    
    return;
}


- (CGFloat)conversationViewController:(ATLConversationViewController *)viewController heightForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth
{
    
    LYRMessagePart *part = message.parts[0];
    
    // if message contains the custom mimetype, then grab the cell info from the other message part
    if([part.MIMEType isEqual: ATLMimeTypeCustomObject])
    {
        LYRMessagePart *cellMessagePart = message.parts[1];
        NSData *data = cellMessagePart.data;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        
        // Grab the height value from the JSON
        NSString *height = [json objectForKey:@"height"];
        NSInteger heightInt = [height integerValue];
        return heightInt;
    }
    return 0;
}


// How do I implement an avatar identical to those normally presented OR show nothing at all?
- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem{
    
}


@end

