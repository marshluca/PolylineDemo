//
//  ViewController.m
//  PolylineDemo
//
//  Created by Lin Zhang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize points = _points;
@synthesize mapView = _mapView;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;
@synthesize locationManager = _locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // setup map view
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userInteractionEnabled = YES;    
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;        
    [self.view addSubview:self.mapView];
    
    // configure location manager
    // [self configureLocationManager];
    
    [self configureRoutes];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.mapView = nil;
	self.routeLine = nil;
	self.routeLineView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark
#pragma mark Map View

- (void)configureRoutes
{
    // define minimum, maximum points
	MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f); 
	MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f); 
	
	// create a c array of points. 
	MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
	// for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < _points.count; idx++)
	{        
        CLLocation *location = [_points objectAtIndex:idx];  
        CLLocationDegrees latitude  = location.coordinate.latitude;
		CLLocationDegrees longitude = location.coordinate.longitude;		 
        
		// create our coordinate and add it to the correct spot in the array 
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
		
		// if it is the first point, just use them, since we have nothing to compare to yet. 
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		} else {
			if (point.x > northEastPoint.x) 
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x) 
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y) 
				southWestPoint.y = point.y;
		}
        
		pointArray[idx] = point;        
	}
	
    if (self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
    }
    
    self.routeLine = [MKPolyline polylineWithPoints:pointArray count:_points.count];
    
    // add the overlay to the map
	if (nil != self.routeLine) {
		[self.mapView addOverlay:self.routeLine];
	}
    
    // clear the memory allocated earlier for the points
	free(pointArray);	
    
    /*
     double width = northEastPoint.x - southWestPoint.x;
     double height = northEastPoint.y - southWestPoint.y;
     
     _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);    	
     
     // zoom in on the route. 
     [self.mapView setVisibleMapRect:_routeRect];
     */
}

/*
 #pragma mark
 #pragma mark Location Manager
 
 - (void)configureLocationManager
 {
 // Create the location manager if this object does not already have one.
 if (nil == _locationManager)
 _locationManager = [[CLLocationManager alloc] init];
 
 _locationManager.delegate = self;
 _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
 _locationManager.distanceFilter = 50;
 [_locationManager startUpdatingLocation];    
 // [_locationManager startMonitoringSignificantLocationChanges];
 }
 
 #pragma mark
 #pragma mark CLLocationManager delegate methods
 - (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 
 // If it's a relatively recent event, turn off updates to save power
 NSDate* eventDate = newLocation.timestamp;
 NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];    
 
 if (abs(howRecent) < 2.0)
 {
 NSLog(@"recent: %g", abs(howRecent));        
 NSLog(@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
 }
 
 // else skip the event and process the next one
 }
 
 - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 NSLog(@"error: %@",error);
 }
 */

#pragma mark
#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"overlayViews: %@", overlayViews);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));

	MKOverlayView* overlayView = nil;
	
	if(overlay == self.routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now. 
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }
        
        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 10;
        
		overlayView = self.routeLineView;		
	}
	
	return overlayView;
}

/*
 - (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
 {
 NSLog(@"mapViewWillStartLoadingMap:(MKMapView *)mapView");
 }
 
 - (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
 {
 NSLog(@"mapViewDidFinishLoadingMap:(MKMapView *)mapView");
 } 
 
 - (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
 {
 NSLog(@"mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error");
 }
 
 - (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
 {
 NSLog(@"mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated");
 NSLog(@"%f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);    
 }
 
 - (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 NSLog(@"centerCoordinate: %f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);    
 }
 */ 

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"annotation views: %@", views);
}

/*
 - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 }
 
 - (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
 {
 NSLog(@"mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated");
 }
 
 - (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"mapViewWillStartLocatingUser:(MKMapView *)mapView");
 }
 
 - (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"mapViewDidStopLocatingUser:(MKMapView *)mapView");
 }
*/ 

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude 
                                                      longitude:userLocation.coordinate.longitude];
    // check the zero point
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    
    // check the move distance
    if (_points.count > 0) {        
        CLLocationDistance distance = [location distanceFromLocation:_currentLocation];        
        if (distance < 5) 
            return;        
    }        
    
    if (nil == _points) {
        _points = [[NSMutableArray alloc] init];
    }
    
    [_points addObject:location];	
    _currentLocation = location;
    
    NSLog(@"points: %@", _points);
    
    [self configureRoutes];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

@end