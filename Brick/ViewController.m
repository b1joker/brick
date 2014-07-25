//
//  ViewController.m
//  Brick
//
//  Created by Gin on 7/24/14.
//  Copyright (c) 2014 Nguyễn Huỳnh Lâm. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController () <AVAudioPlayerDelegate, UIAlertViewDelegate>
{
    NSTimer *_timer;
    CGRect _boundRect;
    float _vX;
    float _vY;
    float time;
    long start,gameOver,count,totalBrick;
    BOOL check[35];
    NSArray *lv1;
    AVAudioPlayer *audioPlayer;
    SystemSoundID touchBrick,die,victory;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *ball;
@property (weak, nonatomic) IBOutlet UIImageView *bar;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    self.bar.userInteractionEnabled = YES;
    self.bar.multipleTouchEnabled = YES;
	[self.bar addGestureRecognizer: panGesture];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"soundBackground"
                                              ofType:@"mp3"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    self->audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                      error:&error];
    audioPlayer.delegate = self;
    audioPlayer.numberOfLoops = -1;
    [self->audioPlayer play];
    NSURL *soundX = [NSURL fileURLWithPath:[[NSBundle mainBundle]	pathForResource:@"touchBrick" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge  CFURLRef) soundX, 	&touchBrick);
    NSURL *soundY = [NSURL fileURLWithPath:[[NSBundle mainBundle]	pathForResource:@"die" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge  CFURLRef) soundY, 	&die);
    NSURL *soundZ = [NSURL fileURLWithPath:[[NSBundle mainBundle]	pathForResource:@"victory" ofType:@"mp3"]];
    AudioServicesCreateSystemSoundID((__bridge  CFURLRef) soundZ, 	&victory);

    
    gameOver = 0;
    totalBrick = 0;
    lv1 =  @[@0, @0,@1,@1,@0,
             @2,@3,@3,@2,
             @2,@3,@3,@2,
             @2,@3,@3,@2,
             @0,@1,@1,@0,
             @1,@1,@1,@1,
             @1,@1,@1,@1,
             @1,@0,@0,@1];
    
    [self solve];
    
}

-(void) showAlert
{
    [self->audioPlayer pause];

    if(count != 26)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                    message:@"Game Over!!!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];

        AudioServicesPlaySystemSound(die);

        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulation"
                                                        message:@"Victory!!!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        AudioServicesPlaySystemSound(victory);

        [alert show];
    }

}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) makeArray
{
    for(int i=1;i<=32;i++)
    {
        check[i] = YES; // rs mảng
        UIImageView *brick = (UIImageView*)[self.view viewWithTag:i];
        
        if([lv1[i]  isEqual: @0])
        {
            check[i] = NO;
            brick.image = nil;
        }
        else
        {
            totalBrick++;
            if([lv1[i]  isEqual: @1])
                brick.image = [UIImage imageNamed:@"redBrick.png"]; // 1 hit
            if([lv1[i]  isEqual: @2])
                brick.image = [UIImage imageNamed:@"yellowBrick.png"]; // 2 hit
            if([lv1[i]  isEqual: @3])
                brick.image = [UIImage imageNamed:@"greenBrick.png"]; // 3 hit
        }
        
    }
}

-(void)solve
{
    count = 0;
    
    _boundRect = self.view.bounds;
    _vX = -1;
    _vY = -1;
    start = 0;
    [self makeArray];
    time = 0.002 + totalBrick*0.0001;

}

- (void) startAnimation
{
    _timer = [NSTimer scheduledTimerWithTimeInterval: time
                                              target: self
                                            selector: @selector(animate:)
                                            userInfo: nil
                                             repeats: YES];
    [_timer fire];
    
}

-(void) checkBall
{
    CGPoint ballCenter = self.ball.center;
    CGSize ballSize = self.ball.bounds.size;
    
    if(count == totalBrick)
    {
        [_timer invalidate];
        [self showAlert];
    }
    
    for(int i=1;i<=32;i++)
    {
        if(check[i] == YES) // còn mới tính
        {
            UIImageView *brick = (UIImageView*)[self.view viewWithTag:i];

            if(     ((ballCenter.x + ballSize.width/2 >= brick.center.x - brick.bounds.size.width/2 // x nam ben trong
                      && ballCenter.x + ballSize.width/2 <= brick.center.x + brick.bounds.size.width/2)
               
                     ||
                     
                     (ballCenter.x - ballSize.width/2 >= brick.center.x - brick.bounds.size.width/2
                      && ballCenter.x - ballSize.width/2 <= brick.center.x + brick.bounds.size.width/2 ))
                
            &&      ((ballCenter.y + ballSize.height/2 <= brick.center.y - brick.bounds.size.height/2 + 5 // y ben ngoai
                      && ballCenter.y + ballSize.height/2 >= brick.center.y + brick.bounds.size.height/2 - 5)
                     
                     ||
                     
                     (ballCenter.y - ballSize.height/2 <= brick.center.y - brick.bounds.size.height/2 + 5
                      && ballCenter.y - ballSize.height/2 >= brick.center.y + brick.bounds.size.height/2 - 5)))
               {
                   AudioServicesPlaySystemSound(touchBrick);
                   _vY = -_vY;
                   if([brick.image isEqual:[UIImage imageNamed:@"greenBrick.png"]])
                       brick.image = [UIImage imageNamed:@"yellowBrick.png"];
                   else if([brick.image isEqual:[UIImage imageNamed:@"yellowBrick.png"]])
                       brick.image = [UIImage imageNamed:@"redBrick.png"];
                   else
                   {
                       count++;
                       brick.image = nil;
                       check[i] = NO;
                       
                       
                       [_timer invalidate];
                       _timer = nil;
                       time-=0.0001;
                       [self startAnimation];
                       
                   }
                   
                   
                   return;

               }
            
            
            else if(   ((ballCenter.x + ballSize.width/2 <= brick.center.x - brick.bounds.size.width/2 + 5 // x nam ben ngoai
                    && ballCenter.x + ballSize.width/2 >= brick.center.x + brick.bounds.size.width/2 - 5)
                   
                   ||
                   
                   (ballCenter.x - ballSize.width/2 <= brick.center.x - brick.bounds.size.width/2 + 5
                    && ballCenter.x - ballSize.width/2 >= brick.center.x + brick.bounds.size.width/2  - 5))
            
             
             &&      ((ballCenter.y + ballSize.height/2 >= brick.center.y - brick.bounds.size.height/2 // y ben trong
                       && ballCenter.y + ballSize.height/2 <= brick.center.y + brick.bounds.size.height/2)
                      
                      ||
                      
                      (ballCenter.y - ballSize.height/2 >= brick.center.y - brick.bounds.size.height/2
                       && ballCenter.y - ballSize.height/2 <= brick.center.y + brick.bounds.size.height/2)) )
            {
               
  
                    _vX = -_vX;
                if([brick.image isEqual:[UIImage imageNamed:@"greenBrick.png"]])
                    brick.image = [UIImage imageNamed:@"yellowBrick.png"];
                else if([brick.image isEqual:[UIImage imageNamed:@"yellowBrick.png"]])
                    brick.image = [UIImage imageNamed:@"redBrick.png"];
                else
                {
                    brick.image = nil;
                    check[i] = NO;
                }
                return;
            }
            
        }
    }
}

-(void) animate: (NSTimer*)theTimer
{

    
    CGPoint center = self.ball.center;
    CGSize size = self.ball.bounds.size;
    
    float newX = center.x + _vX;
    float newY = center.y + _vY;

    if ((newX < size.width /2) || (newX > self.view.bounds.size.width - size.width/2))   // đập tường bên trái, phải
        _vX = -_vX;

    if (newY < 40+ size.height /2)  // đập tường trên
        _vY = -_vY;
    
    if((newY > self.view.bounds.size.height - size.height/2)) // đập tường dưới -- game over
    {
        self.ball.image = nil;
        
        [_timer invalidate];
        gameOver = 1;
        [self showAlert];
        return;
    }
    
    if(start > 1 && (self.ball.center.x <= self.bar.center.x + (self.bar.bounds.size.width)/2) // đập vào thanh hứng
    && (self.ball.center.x >= self.bar.center.x - (self.bar.bounds.size.width)/2)
    && (self.ball.center.y + (self.ball.bounds.size.height)/2 + 3 == self.bar.center.y ))
        _vY = -_vY;
    
    newX = center.x + _vX;
    newY = center.y + _vY;
    
    self.ball.center = CGPointMake(newX , newY);
    
    [self checkBall];
}
- (IBAction)stopTimer:(id)sender {
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    } else {
        [self startAnimation];
    }
}


- (void) onPan: (UIPanGestureRecognizer*) gestureRecognizer // di chuyển thanh hứng
{
    start++;
    if(start==1) // di chuyển thanh hứng thì mới bắt đầu
        [self startAnimation];
    
    if(!_timer.isValid || start != 0) // tránh trường hợp pause để ăn gian
    {
        UIView* piece = gestureRecognizer.view;
    
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
            CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
            [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y )];
        
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
        }
    }
    
}


@end
