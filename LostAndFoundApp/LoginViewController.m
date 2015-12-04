//
//  LoginViewController.m
//  LostAndFoundApp
//
//  Created by HoangVu on 10/20/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@interface LoginViewController () <UITabBarDelegate>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if([PFUser currentUser] != nil)
    {
        [self gotoTabbarView];
    }
    else
    {
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        logInViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton|PFLogInFieldsFacebook|
        PFLogInFieldsSignUpButton|PFLogInFieldsPasswordForgotten;

        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
        //self.view.backgroundColor = [UIColor clearColor];
        //self.view.opaque = NO;
    }

}
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self gotoTabbarView];
}



// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"ShowTabbarView"])
    {
   
        [PFFacebookUtils logInInBackgroundWithReadPermissions:@[ @"public_profile", @"email"] block:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
                [self _loadData];
                
            } else {
                NSLog(@"User logged in through Facebook!");
            }
                    if(user)
                    {
                        [self gotoTabbarView];
                    }
        }];
        
    }
    
}

-(void) gotoTabbarView
{
    [self _loadData];
    AppDelegate * delegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
    [delegate.window setRootViewController:nil];
    UIStoryboard *MainStoryboard = [UIStoryboard storyboardWithName:@"Main"                                                             bundle: nil];
    UITabBarController *tabBarController= (UITabBarController*)[MainStoryboard instantiateViewControllerWithIdentifier:@"tabbar"];
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    [tabBar setBarTintColor:UIColorFromRGB(0xB0C4DE)];
    //[tabBar setBackgroundImage:[UIImage new]];
    tabBarItem1.title = @"";
    tabBarItem2.title = @"";
    tabBarItem3.title = @"";
    [tabBarItem1 setSelectedImage:[UIImage imageNamed:@"Your Item1.png"]];
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"Your Item1.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Your Item.png"]];
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"setting1.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"setting.png"]];
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"Add1.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Add.png"]];
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       UIColorFromRGB(0x00BFFF), UITextAttributeTextColor,
                                                       nil] forState:UIControlStateNormal];

    UIColor *titleHighlightedColor = UIColorFromRGB(0x00BFFF);
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       titleHighlightedColor, UITextAttributeTextColor,
                                                       nil] forState:UIControlStateHighlighted];
    //Set color for tintbar
   

    
    delegate.window.rootViewController= tabBarController;
  
}


-(void)_loadData {
    // ...
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name,email,gender,birthday,relationship_status"}];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *userID = userData[@"id"];
            NSString *userName = userData[@"name"];
            NSString *userEmail = userData[@"email"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            NSString *relationship = userData[@"relationship_status"];
            
            NSLog(@"%@", userEmail);
            // Now add the data to the UI elements
            // ...
            
            PFUser *myUser = [PFUser currentUser];
            if(userName!= nil)
            {
                [myUser setObject:userName forKey:@"name"];
            }
            if(birthday!= nil)
            {
                [myUser setObject:birthday forKey:@"birthday"];
            }
            if(userEmail!= nil)
            {
                [myUser setObject:userEmail forKey:@"email"];
            }
            if(gender!= nil)
            {
                [myUser setObject:gender forKey:@"gender"];
            }
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userID]];
            NSData *picturedata = [[NSData alloc] initWithContentsOfURL:pictureURL];
            if(picturedata != nil)
            {
                PFFile *profileFile = [PFFile fileWithData:picturedata];
                [myUser setObject:profileFile forKey:@"profile_picture"];
            }
            
            [myUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded)
                {
                    NSLog(@"User details are update");
                }
            }];
            
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
