//
//  KBRPClient.m
//  Keybase
//
//  Created by Gabriel on 12/15/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "KBRPClient.h"
#import "KBRPC.h"
#import "AppDelegate.h"

#import <MPMessagePack/MPMessagePackServer.h>
#import "KBDefines.h"

@interface KBRPClient ()
@property MPMessagePackClient *client;

@property MPMessagePackServer *server;
@end

@implementation KBRPClient

- (void)open {
  _client = [[MPMessagePackClient alloc] initWithName:@"KBRPClient" options:MPMessagePackOptionsFramed];
  _client.delegate = self;
  
  NSString *user = [NSProcessInfo.processInfo.environment objectForKey:@"USER"];
  NSAssert(user, @"No user");
  
  GHDebug(@"Connecting to keybased (%@)...", user);
  [_client openWithSocket:NSStringWithFormat(@"/tmp/keybase-%@/keybased.sock", user) completion:^(NSError *error) {
    if (error) {
      GHDebug(@"Error connecting to keybased: %@", error);
      // Retry
      [self openAfterDelay:2];
      return;
    }
    
    [self checkStatus];
  }];
}

- (void)openAfterDelay:(NSTimeInterval)delay {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self open];
  });
}

- (void)checkStatus {
  KBRConfig *config = [[KBRConfig alloc] initWithClient:self];
  [config getCurrentStatus:^(NSError *error, KBGetCurrentStatusRes *getCurrentStatusRes) {
    if (error) {
      // TODO
    }
    GHDebug(@"status: %@", getCurrentStatusRes);
    
    if (!getCurrentStatusRes.loggedIn) {
      [AppDelegate.sharedDelegate showLogin];
    }
    
  }];
}

- (void)sendRequestWithMethod:(NSString *)method params:(id)params completion:(MPRequestCompletion)completion {
  if (_client.status != MPMessagePackClientStatusOpen) {
    completion(KBMakeError(-400, @"We are unable to connect to the keybased client.", @""), nil);
    return;
  }
        
  [_client sendRequestWithMethod:method params:params completion:completion];
}

#pragma mark -

- (void)client:(MPMessagePackClient *)client didError:(NSError *)error fatal:(BOOL)fatal {
  
}

- (void)client:(MPMessagePackClient *)client didChangeStatus:(MPMessagePackClientStatus)status {
  if (status == MPMessagePackClientStatusClosed) {
    //[self openAfterDelay:2];
  } else if (status == MPMessagePackClientStatusOpen) {
    
  }
}

- (void)client:(MPMessagePackClient *)client didReceiveNotificationWithMethod:(NSString *)method params:(id)params {
  
}

@end
