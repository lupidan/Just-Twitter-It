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

#import "JustTwitterItViewController.h"

/**
	The URL to perform a twitter web login using the mobile version
 */
#define JUSTTWEETIT_TWITTER_LOGIN_URL @"https://mobile.twitter.com/login"
/**
	The URL to perform an intent to post a tweet in the timeline
 */
#define JUSTTWEETIT_TWEET_INTENT_URL  @"https://twitter.com/intent/tweet"


@interface JustTwitterItViewController ()

/**
	If NO, it means the user is not going to tweet yet. If YES, it means the user has started the tweet intent.
 */
@property (nonatomic,assign) BOOL userWillTweet;
/**
	The web view to perform all the process
 */
@property (nonatomic,retain) UIWebView * mainWebView;
/**
	An overlay view used when loading
 */
@property (nonatomic,retain) UIView * overlayView;
/**
	An activity indicator view used when loading
 */
@property (nonatomic,retain) UIActivityIndicatorView * activityIndicator;
/**
	A back button used to allow the user to cancel the process
 */
@property (nonatomic,retain) UIButton * backButton;



/**
	Class method. Clears all the expired twitter cookies. Always done before checking if the user is logged in or not
 */
+ (void) clearExpiredTwitterCookies;


/**
	Common init method
 */
- (void) justTweetItViewControllerCommonInit;
/**
	Method executed when the back button was pressed
 */
- (void) backButtonTouchUpInside;
/**
	Creates the URL to perform the tweet intent with the message
	@returns A NSURL object to load in the web view, and perform the tweet intent
 */
- (NSURL*) getTweetIntentFullUrl;

@end







@implementation JustTwitterItViewController
@synthesize message = _message;
@synthesize delegate = _delegate;
@synthesize userWillTweet = _userWillTweet;
@synthesize mainWebView = _mainWebView;
@synthesize overlayView = _overlayView;
@synthesize activityIndicator = _activityIndicator;
@synthesize backButton = _backButton;





#pragma mark - Class methods

+ (BOOL) twitterUserIsLoggedIn{
    BOOL result = NO;
    //Clear expired cookies
    [self clearExpiredTwitterCookies];
    //Search for cookie oauth_token from a mobile.twitter.com domain
    for (NSHTTPCookie * cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies){
        //If we found it, we are logged in and we can tweet!
        if ([cookie.name isEqualToString:@"oauth_token"] && [cookie.domain isEqualToString:@"mobile.twitter.com"])
            result = YES;
    }
    return result;
}

+ (void) twitterUserLogout{

    NSMutableArray * cookiesToDelete = [NSMutableArray array];
    //Delete all cookies from twitter domain
    for (NSHTTPCookie * cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies){
        //If the domain contains twitter, take it to delete
        if ((cookie.domain) && ([cookie.domain rangeOfString:@"twitter"].location != NSNotFound))
            [cookiesToDelete addObject:cookie];
    }
    //Delete all the selected cookies
    for (NSHTTPCookie * cookie in cookiesToDelete)
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];

}

+ (void) clearExpiredTwitterCookies{

    NSMutableArray * cookiesToDelete = [NSMutableArray array];
    //Check the expiration date of all the twitter cookies, and delete the expired ones
    for (NSHTTPCookie * cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies)
        //If the domain contains twitter
        if ((cookie.domain) && ([cookie.domain rangeOfString:@"twitter"].location != NSNotFound))
            //If the cookie expirantion is earlier than now, is expired
            if ((cookie.expiresDate) && ([cookie.expiresDate earlierDate:[NSDate date]] == cookie.expiresDate))
                [cookiesToDelete addObject:cookie];
            
    //Delete the selected cookies
    for (NSHTTPCookie * cookie in cookiesToDelete)
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    
}











#pragma mark - Init and dealloc methods

- (id) init{
    self = [super init];
    if (self){
        [self justTweetItViewControllerCommonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self justTweetItViewControllerCommonInit];
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self justTweetItViewControllerCommonInit];
    }
    return self;
}

- (void) justTweetItViewControllerCommonInit{
    //Nothing we need, but maybe in the future :)
    self.userWillTweet = NO;
}



- (void) dealloc{
    [_mainWebView release];
    [_overlayView release];
    [_activityIndicator release];
    [_backButton release];
    [_message release];
    [super dealloc];
}










#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //Alloc and add the webView
    self.mainWebView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
    self.mainWebView.delegate = self;
    self.mainWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mainWebView];
    
    //Alloc and add the overlay view
    self.overlayView = [[[UIView alloc] initWithFrame:self.mainWebView.bounds] autorelease];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.overlayView setHidden:YES];
    [self.mainWebView addSubview:self.overlayView];
    
    //Alloc and add the loading activity
    self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    self.activityIndicator.center = CGPointMake(self.overlayView.bounds.size.width/2.0,
                                                self.overlayView.bounds.size.height/2.0);
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator stopAnimating];
    [self.overlayView addSubview:self.activityIndicator];
    
    //Alloc and add the back button
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * backImage = [UIImage imageNamed:@"twitter_leave.png"];
    [self.backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(0.0, self.view.bounds.size.height - backImage.size.height,
                                       backImage.size.width, backImage.size.height);
    [self.backButton addTarget:self action:@selector(backButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    

}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Load the web with a request
    NSURLRequest * request = nil;
    //If the user is not logged in, send him to the login web
    if (![JustTwitterItViewController twitterUserIsLoggedIn]){
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:JUSTTWEETIT_TWITTER_LOGIN_URL]];
    }
    //If the user is logged in, send him to the tweet part
    else{
        request = [NSURLRequest requestWithURL:[self getTweetIntentFullUrl]];
        self.userWillTweet = YES;
    }
    [self.mainWebView loadRequest:request];
    
}


- (void)viewDidUnload{
    //Release all views
    [self setMainWebView:nil];
    [self setOverlayView:nil];
    [self setActivityIndicator:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}








#pragma mark - Other private methods

- (void) backButtonTouchUpInside{
    //Cancel the loading
    [self.mainWebView stopLoading];
    //Notify delegate
    if ([self.delegate respondsToSelector:@selector(twitterDidCancel:)])
        [self.delegate twitterDidCancel:self];
}


- (NSURL*) getTweetIntentFullUrl{
    
    NSString * fullUrlString = JUSTTWEETIT_TWEET_INTENT_URL;
    //If a message is defined, create the intent with it
    if (self.message){
        fullUrlString = [[NSString stringWithFormat:@"%@?text=%@",
                          JUSTTWEETIT_TWEET_INTENT_URL, self.message]
                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return [NSURL URLWithString:fullUrlString];
}








#pragma mark - UI Web View Delegate

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    BOOL shouldLoadNextPage = YES;
    
    //If navigation type is different of Other or FormSubmitted, do not load next page
    if ((navigationType != UIWebViewNavigationTypeOther) && (navigationType != UIWebViewNavigationTypeFormSubmitted)){
        shouldLoadNextPage = NO;
    }
    //If I am logged in and
    else{
        
        //If the user is already logged in
        if ([JustTwitterItViewController twitterUserIsLoggedIn]){
            //If the user has not yet started the tweet process
            if (!self.userWillTweet){
                //Load request to tweet a message (we are logged in)
                NSURLRequest * newRequest = [NSURLRequest requestWithURL:[self getTweetIntentFullUrl]];
                self.userWillTweet = YES;
                [self.mainWebView loadRequest:newRequest];
                shouldLoadNextPage = NO;
                //Notify the delegate of the login
                if ([self.delegate respondsToSelector:@selector(twitterUserDidLogin:)])
                    [self.delegate twitterUserDidLogin:self];
            }
            //If the user has started the tweet process
            else{
                //And we detect a session last path component, it means the user has logged out
                if ([request.URL.lastPathComponent isEqualToString:@"session"]){
                    //Force deleting the cookies
                    [JustTwitterItViewController twitterUserLogout];
                    shouldLoadNextPage = NO;
                    //Notify the delegate of the logout
                    if ([self.delegate respondsToSelector:@selector(twitterUserDidLogout:)])
                        [self.delegate twitterUserDidLogout:self];
                    
                }
                //If we detect a complete last path component, it means the user has sucessfully tweeted
                else if ([request.URL.lastPathComponent isEqualToString:@"complete"]){
                    shouldLoadNextPage = NO;
                    //Notify the delegate of the tweet
                    if ([self.delegate respondsToSelector:@selector(twitterUserDidTweet:)])
                        [self.delegate twitterUserDidTweet:self];
                }
            }
        }

    }
    
    return shouldLoadNextPage;
}

- (void) webViewDidStartLoad:(UIWebView *)webView{
    //Show loading view
    [self.overlayView setHidden:NO];
    [self.activityIndicator startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    //Hide loading view
    [self.overlayView setHidden:YES];
    [self.activityIndicator stopAnimating];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    //Notify delegate
    if ([self.delegate respondsToSelector:@selector(twitterDidFail:withError:)])
        [self.delegate twitterDidFail:self withError:error];
    //And hide overlay view
    [self.overlayView setHidden:YES];
    [self.activityIndicator stopAnimating];
}

@end
