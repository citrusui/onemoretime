#include "GPMTMiscListController.h"
#include <spawn.h>

#define OneMoreTimePreferencePath "/User/Library/Preferences/com.onemoretweak.OneMoreTime.plist"

@implementation GPMTMiscListController

+ (NSString *)hb_specifierPlist {
	return @"Misc";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:34.f / 255.f green:40.f / 255.f blue:34.f / 255.f alpha:1];
}

-(id) readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *OneMoreTimeSettings = [NSDictionary dictionaryWithContentsOfFile:@OneMoreTimePreferencePath];
	if (!OneMoreTimeSettings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}
	return OneMoreTimeSettings[specifier.properties[@"key"]];
}
 
-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:@OneMoreTimePreferencePath]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:@OneMoreTimePreferencePath atomically:YES];
	//NSDictionary *OneMoreTimeSettings = [NSDictionary dictionaryWithContentsOfFile:@OneMoreTimePreferencePath];
	CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
	if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

-(void) springBoardCanFuckingDie:(PSSpecifier *)specifier {
	const char* args[] = {"killall", "-9", "SpringBoard", NULL};
	posix_spawn(NULL, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}
@end
