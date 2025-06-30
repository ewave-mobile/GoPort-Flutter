#ifndef FLUTTER_FLUTTER_H_
#define FLUTTER_FLUTTER_H_

#import <UIKit/UIKit.h>

typedef struct _FlutterEngine* FlutterEngine;
typedef struct _FlutterViewController* FlutterViewController;

@protocol FlutterPlugin <NSObject>
@required
+ (void)registerWithRegistrar:(NSObject *)registrar;
@end

#endif  // FLUTTER_FLUTTER_H_
