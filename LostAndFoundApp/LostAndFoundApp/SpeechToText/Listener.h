//
//  Listener.h
//  MyBestFriend
//
//  Created by HYUBYN on 10/20/15.
//  Copyright © 2015 HYUBYN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <speex/speex.h>
#import "SineWaveViewController.h"

#define kNumberBuffers 3
#define kNumVolumeSamples 10
#define kSilenceThresholdDB -30.0

#define kVolumeSamplingInterval 0.05
#define kSilenceTimeThreshold 0.9
#define kSilenceThresholdNumSamples kSilenceTimeThreshold / kVolumeSamplingInterval

// For scaling display
#define kMinVolumeSampleValue 0.01
#define kMaxVolumeSampleValue 1.0
typedef struct AQRecorderState {
    AudioStreamBasicDescription  mDataFormat;
    AudioQueueRef                mQueue;
    AudioQueueBufferRef          mBuffers[kNumberBuffers];
    UInt32                       bufferByteSize;
    SInt64                       mCurrentPacket;
    bool                         mIsRunning;
    
    SpeexBits                    speex_bits;
    void *                       speex_enc_state;
    int                          speex_samples_per_frame;
    __unsafe_unretained NSMutableData *              encodedSpeexData;
    
    __unsafe_unretained id selfRef;
} AQRecorderState;

@protocol ListenerDelegate <NSObject>

// Delegate will need to parse JSON and dismiss loading view if presented
// returns true on success, false on failure
- (BOOL)didReceiveVoiceResponse:(NSData *)data;

@optional
- (void)showSineWaveView:(SineWaveViewController *)view;
- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled;
- (void)showLoadingView;
- (void)requestFailedWithError:(NSError *)error;
@end

@interface Listener : NSObject <UIAlertViewDelegate, SineWaveViewDelegate> {
    UIAlertView *status;
    
    AQRecorderState aqData;
    
    BOOL detectedSpeech;
    int samplesBelowSilence;
    
    NSTimer *meterTimer;
    BOOL processing;
    
    NSMutableArray *volumeDataPoints;
    SineWaveViewController *sineWave;
    
    NSThread *processingThread;
}

@property (readonly) BOOL recording;
@property (assign) id<ListenerDelegate> delegate;

/* Caller can pass a non-nil nib name to specify the nib with which to create
 a SineWaveViewController (nib should conform to the spec in the SineWaveViewController
 interface). A nil argument will cause the module to display an alert view instead
 of the custom view controller. */
- (id)initWithCustomDisplay:(NSString *)nibName;

// Begins a voice recording
- (void)beginRecording;

// Stops a voice recording. The startProcessing parameter is intended for internal use,
// so don't pass NO unless you really mean it.
- (void)stopRecording:(BOOL)startProcessing;

@end