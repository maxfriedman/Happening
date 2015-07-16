@import UIKit;

@class BTNDropinButton, BTNVenue;

@interface BTNDropinButtonCell : UITableViewCell

/// The ID of the button this cell represents.
@property (nonatomic, copy) IBInspectable NSString *buttonId;


/// The dropin button that displays the use case action (e.g. Get a ride).
@property (nonatomic, strong) IBOutlet BTNDropinButton *dropinButton;


/**
 Prepares the cell for display with contextually relevant data.
 @param context A NSDictionary object providing context relevant to displaying the button.
 @param completionHandler A block to be executed upon completion of preparation.
 
 @note The button will not be visible until preparation has completed successfully.
 You should set a completion handler in order to do any work in your view hierarchy
 based on the value of `isDisplayable`. For example, you may want to remove a cell
 from your tableView if the button is not displayable.
 */
- (void)prepareForDisplayWithContext:(NSDictionary *)context
                          completion:(void(^)(BOOL isDisplayable))completionHandler;


/**
 Prepares the cell for display with a venue.
 @param venue A venue object relevant to displaying the button.
 @param completionHandler A block to be executed upon completion of preparation.
 
 @note The button will not be visible until preparation has completed successfully.
 You should set a completion handler in order to do any work in your view hierarchy
 based on the value of `isDisplayable`. For example, you may want to remove a cell
 from your tableView if the button is not displayable.
 */
- (void)prepareForDisplayWithVenue:(BTNVenue *)venue
                        completion:(void(^)(BOOL isDisplayable))completionHandler;

@end
