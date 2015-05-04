/*
     File: APLViewController.m
 Abstract: Application delegate class.
  Version: 3.5
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "APLViewController.h"
#import "Reachability.h"

#include <ifaddrs.h>
#include <arpa/inet.h>


#import <mach/mach.h>


//MARK: Required import
#import <sys/utsname.h>


@interface APLViewController ()

@property (nonatomic, weak) IBOutlet UILabel* summaryLabel;

@property (nonatomic, weak) IBOutlet UITextField *remoteHostLabel;
@property (nonatomic, weak) IBOutlet UIImageView *remoteHostImageView;
@property (nonatomic, weak) IBOutlet UITextField *remoteHostStatusField;

@property (nonatomic, weak) IBOutlet UIImageView *internetConnectionImageView;
@property (nonatomic, weak) IBOutlet UITextField *internetConnectionStatusField;

@property (nonatomic, weak) IBOutlet UIImageView *localWiFiConnectionImageView;
@property (nonatomic, weak) IBOutlet UITextField *localWiFiConnectionStatusField;

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end




@implementation APLViewController

- (void)viewDidLoad
{
    self.summaryLabel.hidden = YES;

    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.apple.com";
    NSString *remoteHostLabelFormatString = NSLocalizedString(@"Remote Host: %@", @"Remote host label format string");
    self.remoteHostLabel.text = [NSString stringWithFormat:remoteHostLabelFormatString, remoteHostName];
    
	self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
	[self.hostReachability startNotifier];
	[self updateInterfaceWithReachability:self.hostReachability];

    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
	[self updateInterfaceWithReachability:self.internetReachability];

    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
	[self.wifiReachability startNotifier];
	[self updateInterfaceWithReachability:self.wifiReachability];
    
    
    //IP ADDRESS
    NSLog(@" IP address=%@",[self getIPAddress]);
    
    
    
    //APP NAME
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
    NSLog(@" APP NAME=%@" , prodName );

    
    
    // CURRENT TIME AND DATE
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    NSLog(@"User's current time in their preference format:%@",currentTime);

    
    //SYSTEM VERSIOn
    NSLog(@"IOS Veriosn:%@",[[UIDevice currentDevice] systemVersion]);

    
    // APP VERSIOn
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"APP VERIOSN:%@",version);

    
    //BUILD VERSION
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSLog(@"BUILD VERSION:%@",build);


    //Locale
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"Language:%@",language);

    //IPHONE NAME
    NSLog(@"IPHONE NAME:%@",[self deviceModelName]);

    
    
    // DEVICE ORIENTATION

    if ([[UIDevice currentDevice ]orientation]==UIDeviceOrientationUnknown) {
        NSLog(@"ORIENTATION:UIDeviceOrientationUnknown");

    }
    else if ([[UIDevice currentDevice ]orientation]==UIDeviceOrientationPortrait) {
        NSLog(@"ORIENTATION:UIDeviceOrientationPortrait");

    }
    else if ([[UIDevice currentDevice ]orientation]==UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"ORIENTATION:UIDeviceOrientationPortraitUpsideDown");

    }
    else if ([[UIDevice currentDevice ]orientation]==UIDeviceOrientationLandscapeLeft) {
        NSLog(@"ORIENTATION:UIDeviceOrientationLandscapeLeft");

    }
    else if ([[UIDevice currentDevice ]orientation]==UIDeviceOrientationLandscapeRight) {
        NSLog(@"ORIENTATION:UIDeviceOrientationLandscapeRight");

    }
    else if ([[UIDevice currentDevice ]orientation]==UIDeviceOrientationFaceUp) {
        NSLog(@"ORIENTATION:UIDeviceOrientationFaceUp");

    }
    else if ([[UIDevice currentDevice ]orientation]==UIDeviceOrientationFaceDown) {
        NSLog(@"ORIENTATION:UIDeviceOrientationFaceDown");
    }

    
    
    //HIEGHT AND WIDTH
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

    NSLog(@"WIDTH  :%F", screenWidth);
    NSLog(@"Height :%F",screenHeight);



    //DEVICE MEMORY.
    NSLog(@"physical memory: %llu", [NSProcessInfo processInfo].physicalMemory);
    NSLog(@"getFreeDiskspace: %llu", [self getFreeDiskspace]/1024);


    //GET_USAGE_MEMORY_IOS_APP
    //    NSLog(@"report_memory=%@",[self report_memory]);
        [self report_memory];



}

#pragma APP_MEMORY

//GET_MEMORY USED BY APPLICATIOM
-(void)report_memory {
    
    static unsigned last_resident_size=0;
    static unsigned greatest = 0;
    static unsigned last_greatest = 0;
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        int diff = (int)info.resident_size - (int)last_resident_size;
        unsigned latest = info.resident_size;
        if( latest > greatest   )   greatest = latest;  // track greatest mem usage
        int greatest_diff = greatest - last_greatest;
        int latest_greatest_diff = latest - greatest;
        NSLog(@"Mem: %10u (%10d) : %10d :   greatest: %10u (%d)", info.resident_size, diff,
              latest_greatest_diff,
              greatest, greatest_diff  );
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    last_resident_size = info.resident_size;
    last_greatest = greatest;
}


//GET_MEMORY USED BY APPLICATIOM
-(void)report_memory123{
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    //NSString *Memory;
    
    if( kerr == KERN_SUCCESS ) {
            NSLog(@"Memory in use (in bytes): %u", info.resident_size);
//        [self transformedValue:info.resident_size];
        
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    
}

//Convert to MB,GB
- (id)transformedValue:()value
{
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}


#pragma DEVICE_MEMORY
//DEVICE MEMORY

-(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %@", [error domain], [error code]);
    }
    
    return totalFreeSpace;
}

#pragma IPHONE_NAME

//IPHONE NAME:
- (NSString*)deviceModelName {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //MARK: More official list is at
    //http://theiphonewiki.com/wiki/Models
    //MARK: You may just return machineName. Following is for convenience
    
    NSDictionary *commonNamesDictionary =
    @{
      @"i386":     @"iPhone Simulator",
      @"x86_64":   @"iPad Simulator",
      
      @"iPhone1,1":    @"iPhone",
      @"iPhone1,2":    @"iPhone 3G",
      @"iPhone2,1":    @"iPhone 3GS",
      @"iPhone3,1":    @"iPhone 4",
      @"iPhone3,2":    @"iPhone 4(Rev A)",
      @"iPhone3,3":    @"iPhone 4(CDMA)",
      @"iPhone4,1":    @"iPhone 4S",
      @"iPhone5,1":    @"iPhone 5(GSM)",
      @"iPhone5,2":    @"iPhone 5(GSM+CDMA)",
      @"iPhone5,3":    @"iPhone 5c(GSM)",
      @"iPhone5,4":    @"iPhone 5c(GSM+CDMA)",
      @"iPhone6,1":    @"iPhone 5s(GSM)",
      @"iPhone6,2":    @"iPhone 5s(GSM+CDMA)",
      
      @"iPhone7,1":    @"iPhone 6+ (GSM+CDMA)",
      @"iPhone7,2":    @"iPhone 6 (GSM+CDMA)",
      
      @"iPad1,1":  @"iPad",
      @"iPad2,1":  @"iPad 2(WiFi)",
      @"iPad2,2":  @"iPad 2(GSM)",
      @"iPad2,3":  @"iPad 2(CDMA)",
      @"iPad2,4":  @"iPad 2(WiFi Rev A)",
      @"iPad2,5":  @"iPad Mini 1G (WiFi)",
      @"iPad2,6":  @"iPad Mini 1G (GSM)",
      @"iPad2,7":  @"iPad Mini 1G (GSM+CDMA)",
      @"iPad3,1":  @"iPad 3(WiFi)",
      @"iPad3,2":  @"iPad 3(GSM+CDMA)",
      @"iPad3,3":  @"iPad 3(GSM)",
      @"iPad3,4":  @"iPad 4(WiFi)",
      @"iPad3,5":  @"iPad 4(GSM)",
      @"iPad3,6":  @"iPad 4(GSM+CDMA)",
      
      @"iPad4,1":  @"iPad Air(WiFi)",
      @"iPad4,2":  @"iPad Air(GSM)",
      @"iPad4,3":  @"iPad Air(GSM+CDMA)",
      
      @"iPad4,4":  @"iPad Mini 2G (WiFi)",
      @"iPad4,5":  @"iPad Mini 2G (GSM)",
      @"iPad4,6":  @"iPad Mini 2G (GSM+CDMA)",
      
      @"iPod1,1":  @"iPod 1st Gen",
      @"iPod2,1":  @"iPod 2nd Gen",
      @"iPod3,1":  @"iPod 3rd Gen",
      @"iPod4,1":  @"iPod 4th Gen",
      @"iPod5,1":  @"iPod 5th Gen",
      
      };
    
    NSString *deviceName = commonNamesDictionary[machineName];
    
    if (deviceName == nil) {
        deviceName = machineName;
    }
    
    return deviceName;
}

#pragma IP_ADDRESS

// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
} 


/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
	{
		[self configureTextField:self.remoteHostStatusField imageView:self.remoteHostImageView reachability:reachability];
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];

        self.summaryLabel.hidden = (netStatus != ReachableViaWWAN);
        NSString* baseLabelText = @"";
        
        if (connectionRequired)
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
        self.summaryLabel.text = baseLabelText;
    }
    
	if (reachability == self.internetReachability)
	{
		[self configureTextField:self.internetConnectionStatusField imageView:self.internetConnectionImageView reachability:reachability];
	}

	if (reachability == self.wifiReachability)
	{
		[self configureTextField:self.localWiFiConnectionStatusField imageView:self.localWiFiConnectionImageView reachability:reachability];
	}
}


- (void)configureTextField:(UITextField *)textField imageView:(UIImageView *)imageView reachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString* statusString = @"";
    
    switch (netStatus)
    {
        case NotReachable:        {
            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            imageView.image = [UIImage imageNamed:@"stop-32.png"] ;
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            connectionRequired = NO;
            break;
        }

        case ReachableViaWWAN:        {
            statusString = NSLocalizedString(@"Reachable WWAN", @"");
            imageView.image = [UIImage imageNamed:@"WWAN5.png"];
            break;
        }
        case ReachableViaWiFi:        {
            statusString= NSLocalizedString(@"Reachable WiFi", @"");
            imageView.image = [UIImage imageNamed:@"Airport.png"];
            break;
        }
    }
    
    if (connectionRequired)
    {
        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
    textField.text= statusString;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


@end
