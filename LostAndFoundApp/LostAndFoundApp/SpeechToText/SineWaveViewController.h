//
//  SineWaveViewController.h
//  MyBestFriend
//
//  Created by HYUBYN on 10/20/15.
//  Copyright © 2015 HYUBYN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveDisplay.h"

@protocol SineWaveViewDelegate <NSObject>

- (void)sineWaveDoneAction;
- (void)sineWaveCancelAction;

@end

// Users of this class can create a custom nib conforming to
// the defined IB interface.

@interface SineWaveViewController : UIViewController {
    IBOutlet UILabel *header; // Title header
    IBOutlet UIImageView *backgroundImage;
    
    // Displays a realtime waveform that receives new data from the STTModule during recording
    IBOutlet WaveDisplay *waveDisplay;
    
    // This view can be used if the sine wave controller is repurposed to show a loading screen during
    // voice processing (as it is in Astrid)
    IBOutlet UIView *processingView;
    
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *doneButton;
    
//    IBOutlet UIButton *doneButton;
//    IBOutlet UIButton *cancelButton;
    IBOutlet UITextView *footer;
}

@property (assign) id<SineWaveViewDelegate> delegate;
@property (readonly) WaveDisplay *waveDisplay;
@property (readonly) UIImageView *backgroundView;
@property (readonly) UIView *processingView;
@property (readonly) UIButton *doneButton;
@property (readonly) UIButton *cancelButton;
@property (readonly) UILabel *header;
@property (readonly) UITextView *footer;

// Pointer to the array containing data points for the waveform to draw
@property (nonatomic, retain) NSArray *dataPoints;

// Action sent by doneButton. This passes "done" or "cancel" messages to the delegate,
// which is generally a SpeechToTextModule instance

- (IBAction)done;

- (IBAction)cancel;

// Force the waveform display to update when new data is added
- (void)updateWaveDisplay;

// Resets the view state to the default (see the .m file for what that default is)
- (void)resetViewState;

// Repurposes the done button to be a cancel button
//- (void)repurposeForCancelling;

@end