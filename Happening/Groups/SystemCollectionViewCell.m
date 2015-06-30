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
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height)];
        //backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:backgroundView];
        
        //self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self shouldDisplayAvatarItem:NO];
        
        messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 320-50, backgroundView.frame.size.height)];
        messageLabel.font = [UIFont fontWithName:@"OpenSans" size:10.0];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor darkTextColor];
        messageLabel.numberOfLines = 2;
        [backgroundView addSubview:messageLabel];
        
    }
    return self;
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

- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem{
    
    LYRMessagePart *part = self.message.parts[0];
    
    // if message contains custom mime type then get the text from the MessagePart JSON
    if([part.MIMEType isEqual: ATLMimeTypeSystemObject])
    {
        NSData *data = part.data;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        //self.title.text = [json objectForKey:@"message"];
        
        //return YES;
    }
    
}


@end

