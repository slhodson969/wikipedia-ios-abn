#import <XCTest/XCTest.h>
#import "NSUserActivity+WMFExtensions.h"

@interface NSUserActivity_WMFExtensions_wmf_activityForWikipediaScheme_Test : XCTestCase
@end

@implementation NSUserActivity_WMFExtensions_wmf_activityForWikipediaScheme_Test

- (void)testURLWithoutWikipediaSchemeReturnsNil {
    NSURL *url = [NSURL URLWithString:@"http://www.foo.com"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity);
}

- (void)testInvalidArticleURLReturnsNil {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/Foo"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity);
}

- (void)testArticleURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/wiki/Foo"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeLink);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString, @"https://en.wikipedia.org/wiki/Foo");
}

- (void)testExploreURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://explore"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeExplore);
}

- (void)testSavedURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://saved"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeSavedPages);
}

- (void)testSearchURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/w/index.php?search=dog"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeLink);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString,
                          @"https://en.wikipedia.org/w/index.php?search=dog&title=Special:Search&fulltext=1");
}

- (void)testPlacesURLWithoutParamsReturnsDefaultActivity {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];

    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertEqualObjects(activity.userInfo[@"WMFPage"], @"Places");
    XCTAssertNil(activity.webpageURL);
    XCTAssertNil(activity.userInfo[@"latitude"]);
    XCTAssertNil(activity.userInfo[@"longitude"]);
}

- (void)testPlacesURLWithArticleURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?WMFArticleURL=https://en.wikipedia.org/wiki/Foo"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];

    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertEqualObjects(activity.userInfo[@"WMFPage"], @"Places");
    XCTAssertEqualObjects(activity.webpageURL.absoluteString, @"https://en.wikipedia.org/wiki/Foo");
    XCTAssertNil(activity.userInfo[@"latitude"]);
    XCTAssertNil(activity.userInfo[@"longitude"]);
}

- (void)testPlacesURLWithCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?WMFLatitude=48.8584&WMFLongitude=2.2945"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];

    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertEqualObjects(activity.userInfo[@"WMFPage"], @"Places");
    XCTAssertNil(activity.webpageURL);

    NSNumber *latitude = activity.userInfo[@"latitude"];
    NSNumber *longitude = activity.userInfo[@"longitude"];

    XCTAssertEqual(latitude.doubleValue, 48.8584);
    XCTAssertEqual(longitude.doubleValue, 2.2945);
}

- (void)testPlacesURLWithArticleAndCoordinatesPrefersArticleURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?WMFArticleURL=https://en.wikipedia.org/wiki/Foo&WMFLatitude=48.8584&WMFLongitude=2.2945"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    
    // Article URL takes priority
    XCTAssertNotNil(activity.webpageURL);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString, @"https://en.wikipedia.org/wiki/Foo");

    // Coordinates are ignored
    XCTAssertNil(activity.userInfo[@"latitude"]);
    XCTAssertNil(activity.userInfo[@"longitude"]);
}

@end
