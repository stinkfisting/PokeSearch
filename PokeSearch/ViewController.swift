//
//  ViewController.swift
//  PokeSearch
//
//  Created by Marcus Tam on 2/28/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit
import GeoFire
import FirebaseDatabase
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, MyProtocol {
    
    @IBOutlet weak var mapView: MKMapView!

    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    var valueSentFromPokemonCollectionView: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireRef = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Only want the map to center once when the screen first loads. Otherwise, screen will keep going back to user location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annoIdentifier = "Pokemon"
        var annotationView: MKAnnotationView?
        
        //If this annotation is user location, set image to "ash"
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
        } else {
            // If deqAnno has no reusableAnno, create default annotation here
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        //Customize annotation here
        if let annotationView = annotationView, let anno = annotation as? PokeAnnotation {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pokemonNumber)")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "location-map-flat"), for: .normal)
            annotationView.rightCalloutAccessoryView = btn
        }
        
        return annotationView
        
    }
    
    func createSighting(forLocation location: CLLocation, withPokemon pokeId: Int) {
        
        geoFire.setLocation(location, forKey: "\(pokeId)")
    }
    
    //When creatSighting is called, showSightings will be called. Key will go to "keyEntered"
    func showSightingsOnMap(location: CLLocation) {
        let circleQuery = geoFire!.query(at: location, withRadius: 2.5)
        
        //Whenever we find Key in location, show it on map
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            //Cycle through all pokemon in the location and add Annotations on map
            if let key = key, let location = location {
                let anno = PokeAnnotation(coordinate: location.coordinate, pokemonNumber: Int(key)!)
                self.mapView.addAnnotation(anno)
                //When AddAnnotation is called, viewForAnnotation will be called and lets us customize the annotation
            }
        })
    }
    //When region changes (user pans), show all pokemon sightings
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: loc)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //When you tap map button on pokemon Anno, we want to show apple map directions
        if let anno = view.annotation as? PokeAnnotation {
            // Place is where you start, Destination is where Pokemon is
            
            let place = MKPlacemark(coordinate: anno.coordinate)
//            var place: MKPlacemark!
//            if #available(iOS 10.0, *) {
//                place = MKPlacemark(coordinate: anno.coordinate)
//            } else {
//                place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: nil)
//            }
            let destination = MKMapItem(placemark: place)
            destination.name = "Pokemon Sighting"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey:  NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
        
    }

    @IBAction func spotRandomPokemon(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "PokemonCollectionViewController") as! PokemonCollectionViewController
        
        secondViewController.delegate = self
        
        present(secondViewController, animated: true, completion: nil)

    }
    

    func setResultOfPokeSelection(valueSent: Int)
    {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)

        self.valueSentFromPokemonCollectionView = valueSent
        createSighting(forLocation: loc, withPokemon: self.valueSentFromPokemonCollectionView!)
    }
    
}









