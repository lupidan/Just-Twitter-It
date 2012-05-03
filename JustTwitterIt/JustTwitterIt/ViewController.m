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

#import "ViewController.h"


@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)twitAMessageButtonTouchUpInside:(id)sender {
    JustTwitterItViewController * tweetIt = [[JustTwitterItViewController alloc] init];
    tweetIt.message = @"JustTwittertIt! #JustTwitterIt @lupi_dan https://github.com/lupidan/Just-Twitter-It";
    tweetIt.delegate = self;
    [self presentModalViewController:tweetIt animated:YES];
}

- (IBAction)logoutButtonTouchUpInside:(id)sender {
    [JustTwitterItViewController twitterUserLogout];
}


#pragma mark Just Tweet It Delegate
- (void) twitterUserDidLogin:(JustTwitterItViewController *)controller{

}

- (void) twitterUserDidLogout:(JustTwitterItViewController *)controller{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) twitterUserDidTweet:(JustTwitterItViewController *)controller{
    [self dismissModalViewControllerAnimated:YES];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"The message was sent to your timeline :)" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void) twitterDidCancel:(JustTwitterItViewController*)controller{
    [self dismissModalViewControllerAnimated:YES];
}


- (void) twitterDidFail:(JustTwitterItViewController *)controller{
    
    [self dismissModalViewControllerAnimated:YES];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Information" message:@"There was an error" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


@end
