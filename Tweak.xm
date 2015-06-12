#define OneMoreTimePreferencePath "/User/Library/Preferences/com.onemoretweak.OneMoreTime.plist"

static BOOL enabled, twhr, ucpm, revno;
static NSInteger hourDifference,minuteDifference;
static NSString *separator;

static void OneMoreTimeInitPrefs() {
	NSDictionary *OneMoreTimeSettings = [NSDictionary dictionaryWithContentsOfFile:@OneMoreTimePreferencePath];

	NSNumber *OneMoreTimeEnabled = OneMoreTimeSettings[@"enabled"];
	NSNumber *OneMoreTimeTwelveHour = OneMoreTimeSettings[@"twhr"];
	NSNumber *OneMoreTimeUpperCasePM = OneMoreTimeSettings[@"ucpm"];
	NSNumber *OneMoreTimeReverse = OneMoreTimeSettings[@"revno"];
	NSNumber *OneMoreTimeHourDiff = OneMoreTimeSettings[@"hourdiff"];
	NSNumber *OneMoreTimeMinuteDiff = OneMoreTimeSettings[@"minutediff"];
	NSString *OneMoreTimeSeparator = OneMoreTimeSettings[@"separator"];
	
	enabled = OneMoreTimeEnabled ? [OneMoreTimeEnabled boolValue] : 0;
	twhr = OneMoreTimeTwelveHour ? [OneMoreTimeTwelveHour boolValue] : 0;
	ucpm = OneMoreTimeUpperCasePM ? [OneMoreTimeUpperCasePM boolValue] : 0;
	revno = OneMoreTimeReverse ? [OneMoreTimeReverse boolValue] : 0;
	hourDifference = OneMoreTimeHourDiff ? [OneMoreTimeHourDiff integerValue] : 0;
	minuteDifference = OneMoreTimeMinuteDiff ? [OneMoreTimeMinuteDiff integerValue] : 0;
	separator = OneMoreTimeSeparator ? OneMoreTimeSeparator : @"|";
	if(minuteDifference == 1)
		minuteDifference = 30;
}

%ctor {
	CFNotificationCenterAddObserver(
				CFNotificationCenterGetDarwinNotifyCenter(),
				NULL,
				(CFNotificationCallback)OneMoreTimeInitPrefs,
				CFSTR("com.onemoretweak.OneMoreTime/ReloadPrefs"),
				NULL,
				CFNotificationSuspensionBehaviorCoalesce
	);
	OneMoreTimeInitPrefs();
}

%hook UIStatusBarTimeItemView
- (id)contentsImage
{
	__strong NSString *&timeString = MSHookIvar<NSString *>(self, "_timeString");
	NSDate *date = [NSDate date];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
	NSInteger hour = [components hour];
	NSInteger minute = [components minute];
	NSInteger newHour,newMinute;
	if(minute>=30){
		newHour = minuteDifference == 30 ? hour + hourDifference + 1 : hour + hourDifference;
		newMinute = minute - minuteDifference;
	} else {
		newHour = hour + hourDifference;
		newMinute = minute + minuteDifference;
	}

	if(newHour >= 24)
		newHour -= 24;
	if(newHour < 0)
		newHour += 24;
	
	BOOL PM = NO;
	BOOL newPM = NO;
	if(twhr){
		if(hour > 12){hour -= 12; PM = YES;}
		if(hour == 12){PM = YES;}
		if(hour == 0){hour=12;}
		if(newHour > 12){newHour -= 12; newPM = YES;}
		if(newHour == 12){newPM = YES;}
		if(newHour == 0){newHour=12;}

	}

	NSString *hs, *nhs, *ms, *nms, *twhrs, *ntwhrs;
	if(!twhr){
		hs = hour < 10 ? [NSString stringWithFormat:@"0%ld", (long)hour] : [NSString stringWithFormat:@"%ld", (long)hour];
		nhs = newHour < 10 ? [NSString stringWithFormat:@"0%ld", (long)newHour] : [NSString stringWithFormat:@"%ld", (long)newHour];
		ms = minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)minute] : [NSString stringWithFormat:@"%ld", (long)minute];
		nms = newMinute < 10 ? [NSString stringWithFormat:@"0%ld", (long)newMinute] : [NSString stringWithFormat:@"%ld", (long)newMinute];	
	} else {
		hs = [NSString stringWithFormat:@"%ld", (long)hour];
		nhs = [NSString stringWithFormat:@"%ld", (long)newHour];
		ms = minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)minute] : [NSString stringWithFormat:@"%ld", (long)minute];
		nms = newMinute < 10 ? [NSString stringWithFormat:@"0%ld", (long)newMinute] : [NSString stringWithFormat:@"%ld", (long)newMinute];
	}
	twhrs = PM ? ucpm?@"PM":@"pm" : ucpm?@"AM":@"am";
	ntwhrs = newPM ? ucpm?@"PM":@"pm" : ucpm?@"AM":@"am";
	
	NSString *formedString;
	if(twhr){
		formedString = [[NSString stringWithFormat:@"%@:%@ %@ %@ %@:%@ %@", revno ? nhs : hs, revno ? nms : ms, revno ? ntwhrs : twhrs, separator, revno ? hs : nhs, revno ? ms : nms, revno ? twhrs : ntwhrs] retain];
	} else {
		formedString = [[NSString stringWithFormat:@"%@:%@ %@ %@:%@", revno ? nhs : hs, revno ? nms : ms, separator, revno ? hs : nhs, revno ? ms : nms] retain];
	}
	
	if(enabled){
		timeString = formedString;
	}

	return %orig;
}
%end
