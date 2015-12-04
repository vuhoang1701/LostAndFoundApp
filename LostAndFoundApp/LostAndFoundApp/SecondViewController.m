//
//  SecondViewController.m
//  LostAndFoundApp
//
//  Created by HoangVu on 10/8/15.
//  Copyright © 2015 HoangVu. All rights reserved.
//

#import "SecondViewController.h"
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "LoginViewController.h"
#import "AppDelegate.h"
@interface SecondViewController ()

@end

@implementation SecondViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    PFUser*user = [PFUser currentUser];
    PFFile *thumbnail = [user objectForKey:@"profile_picture"];
    self.imageUser.image = [UIImage imageNamed:@"images.jpeg"];
     self.imageUser.file = thumbnail;
     self.imageUser.layer.cornerRadius = 5;
     self.imageUser.clipsToBounds = YES;
    self.containerSetting.layer.cornerRadius = 15;
    self.containerSetting.clipsToBounds = YES;
    self.containerUser.layer.cornerRadius = 15;
    self.containerUser.clipsToBounds = YES;
    [ self.imageUser loadInBackground];
    
    //Get Item bame

    if( [user objectForKey:@"name"] ==  nil)
    {
        self.lbelUserName.text = [NSString stringWithFormat:@"Username : %@", [user objectForKey:@"username"]];

    }
    else{
        self.lbelUserName.text = [NSString stringWithFormat:@"Name : %@", [user objectForKey:@"name"]];

    }
       self.lbelEmail.text = [NSString stringWithFormat:@"Email : %@", [user objectForKey:@"email"]];
    
    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ibecon.png"]];
    self.view.backgroundColor = [UIColor clearColor];
 

    }




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tapLogout:(id)sender {
    
    [PFUser logOut];
    LoginViewController  *signinView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    UINavigationController *naviSignin =  [[UINavigationController alloc] initWithRootViewController:signinView];
    
    AppDelegate * delegate =(AppDelegate*) [UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = naviSignin;

}
@end
