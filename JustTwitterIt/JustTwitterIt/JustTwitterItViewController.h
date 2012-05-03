/**
 * JustTwitterIt
 *
 * Copyright 2012 Daniel Lupiañez Casares <lupidan@gmail.com>
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 **/

#import <UIKit/UIKit.h>
@class JustTwitterItViewController;

/**
	Protocol to communicate with the controller. It controls whether a user did login, logout, tweet, cancel or failed loading
 */
@protocol JustTwitterItViewDelegate <NSObject>

@optional
/**
	This method is executed when the user logged in twitter successfully
	@param controller The JustTweetItViewDelegate controller that detected this
 */
- (void) twitterUserDidLogin:(JustTwitterItViewController*)controller;
/**
	This method is executed when the user sucessfully tweets a message
	@param controller The JustTweetItViewDelegate controller that detected this
 */
- (void) twitterUserDidTweet:(JustTwitterItViewController*)controller;
/**
	This method is executed when the user performs a logout
	@param controller The JustTweetItViewDelegate controller that detected this
 */
- (void) twitterUserDidLogout:(JustTwitterItViewController*)controller;
/**
	This method is executed when the user press the button to cancel and go back
	@param controller The JustTweetItViewDelegate controller that detected this
 */
- (void) twitterDidCancel:(JustTwitterItViewController*)controller;
/**
	This method is executed when the web view fails when trying to load a webpage
	@param controller The JustTweetItViewDelegate controller that detected this
	@param error The NSError containing the error given by the inner UIWebView
 */
- (void) twitterDidFail:(JustTwitterItViewController*)controller withError:(NSError*)error;

@end







/**
	This View Controller can be used as you want to allow a user to post a tweet
 */
@interface JustTwitterItViewController : UIViewController <UIWebViewDelegate>

/**
	The message to post in the twitter timeline
 */
@property (nonatomic,retain) NSString * message;

/**
	The delegate
 */
@property (nonatomic,assign) id<JustTwitterItViewDelegate> delegate;



/**
	Class method. It checks if, within the application cookies, the twitter login cookie is present. This means, it tells us whether there is a logged user or not
	@returns YES if the user is logged in, NO otherwise
 */
+ (BOOL) twitterUserIsLoggedIn;


/**
	Class method. It forces a logout from twitter by deleting all the cookies from twitter in the application cookie storage
 */
+ (void) twitterUserLogout;


@end
