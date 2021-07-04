import 'dart:async';
import 'dart:io';
import 'package:agrii_ransport/add_widget/AtDivider.dart';
import 'package:agrii_ransport/dataprovider/nearbydriver.dart';
import 'package:agrii_ransport/screens/About.dart';
import 'package:agrii_ransport/screens/Support.dart';
import 'package:agrii_ransport/screens/searchpage.dart';
import 'package:agrii_ransport/styles/styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'searchpage.dart';



class HomePage extends StatefulWidget {

  //navigationPurpose
  static const String id = 'homepage';
    @override
    _HomePageState createState() => _HomePageState();
  }
  
  class _HomePageState extends State<HomePage> with TickerProviderStateMixin {


    GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
    double searchSheetHeight = (Platform.isIOS) ? 160 : 160;
    double rideDetailsSheetHeight = 0;

    double requestingSheetHeight = 0;

    Completer<GoogleMapController> _controller = Completer();
    GoogleMapController mapController;

    double mapBottomPadding = 0;

    List<LatLng> polylineCoordinates = [];
    Set<Polyline> _polylines = {};
    // ignore: non_constant_identifier_names
    Set<Marker> _Markers = {};
    // ignore: non_constant_identifier_names
    Set<Circle> _Circles = {};


    BitmapDescriptor nearbyIcon;


    String addr1 = "";
    String addr2 = "";

    var geoLocator = Geolocator();
    Position _currentPosition;

    bool drawerCanOpen = true; // toogle menu toback button

    DatabaseReference rideRef;

    bool nearbyDriversKeysLoaded = false;


    void setupPositionLocator() async
    {
        Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,);
        _currentPosition = position;

         LatLng pos = LatLng(position.latitude, position.longitude);
         CameraPosition cp = new CameraPosition(target: pos, zoom: 18);
         mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

        startGeofireListener();
    }

    static final CameraPosition _kGooglePlex = CameraPosition
      (
         target: LatLng(37.42796133580664, -122.085749655962),
         zoom: 15.0,
       );

    @override
    Widget build(BuildContext context) {


      return Scaffold(
        key: scaffoldkey,
        drawer: Container(
            width: 250,
             color: Colors.white,
               child: Drawer(
                 child: ListView(
                   padding: EdgeInsets.all(0),

                   children: <Widget>[

                  Container(
                     color: Colors.white,
                     height: 160,
                     child: DrawerHeader(
                         decoration: BoxDecoration
                           (
                              color: Colors.white,
                           ),

                      child: Row(

                        children: <Widget>[

                          Image.asset('images/man.png', height: 60, width: 60,),
                          SizedBox(width: 15,),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[

                              Text('Aditya\nPachpande', style: TextStyle(
                                  fontSize: 20, fontFamily: 'Brand-Bold'),),
                              SizedBox(height: 5,),
                             // Text('View Profile'),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  AtDivider(),
                  SizedBox(height: 10,),

                  ListTile
                    (
                      leading: Icon(Icons.compare_arrows_sharp),
                      title: Text('Trips', style: DrawerItemStyle), //trips
                    ),
                  AtDivider(),

                  ListTile
                    (
                      leading: Icon(Icons.credit_card),
                      title: Text('Payment', style: DrawerItemStyle), //payment
                     ),
                  AtDivider(),

                  ListTile
                    (
                       leading: Icon(Icons.contact_support_rounded),
                        title: Text('Support', style: DrawerItemStyle),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Support(),
                        ),
                      );
                    },
                    ),
                  AtDivider(),

                  ListTile
                    (
                        leading: Icon(Icons.info_rounded),
                         title: Text('About', style: DrawerItemStyle),
                         onTap: () {
                            Navigator.push(
                            context,
                             MaterialPageRoute(
                          builder: (context) => AboutScreen(),
                        ),
                        );
                       },
                     ),
                       AtDivider(),
                   ],
                 ),
               )
             ),

        body: Stack(

          children: <Widget>[

            GoogleMap(
                padding: EdgeInsets.only(bottom: mapBottomPadding),
                mapType: MapType.normal,
                myLocationEnabled: true,
                initialCameraPosition: _kGooglePlex,
                zoomGesturesEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                polylines: _polylines,
                markers: _Markers,
                circles: _Circles,

                onMapCreated: (GoogleMapController controller)
                {
                    _controller.complete(controller);
                    mapController = controller;

                       setState(()
                       {
                             mapBottomPadding = 175;
                       });
                  setupPositionLocator();
                }
            ),


            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 285.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.cyanAccent, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),

                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            ///Menu Button /Drawer Button
            Positioned(
              top: 44,
              left: 20,
              child: GestureDetector(

                onTap: ()
                {
                  if (drawerCanOpen)
                  {
                    scaffoldkey.currentState.openDrawer();
                  }
                  else {
                    //  resetApp();
                  }
                },

                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ),
                        ),
                      ]
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Icon(
                      (drawerCanOpen) ? Icons.menu : Icons.arrow_back_outlined,
                      color: Colors.red,),
                  ),
                ),
              ),
            ),

            /// SearchSheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,

              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  height: searchSheetHeight,

                  decoration: BoxDecoration
                    (
                        color: Colors.white,
                        borderRadius: BorderRadius.only
                        (
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)
                        ),
                      boxShadow:
                      [
                        BoxShadow
                          (
                               color: Colors.black,
                               blurRadius: 15.0,
                               spreadRadius: 0.5,
                               offset: Offset
                                 (
                                     0.7,
                                     0.7
                                 )
                           )
                      ]

                  ),

                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 5,),

                        Text('Your Destination Please...', style: TextStyle(
                            fontSize: 18, fontFamily: 'Brand-Bold'),),

                        SizedBox(height: 20,),

                        GestureDetector(
                          onTap: ()
                          {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => MapView()
                            ));
                          },

                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow:
                                [
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5.0,
                                      spreadRadius: 0.5,
                                      offset: Offset(
                                        0.7,
                                        0.7,
                                      )
                                   ),
                                ]
                             ),

                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                children: <Widget>
                                [
                                  Icon(Icons.search, color: Colors.blueAccent,),
                                  SizedBox(width: 10,),
                                  Text('Search Destination'),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 22,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    void startGeofireListener() {
      Geofire.initialize('driversAvailable');
      Geofire.queryAtLocation(
          _currentPosition.latitude, _currentPosition.latitude, 100).listen((
          map) {
        if (map != null) {
          var callBack = map['callBack'];

          //latitude will be retrieved from map['latitude']
          //longitude will be retrieved from map['longitude']

          switch (callBack) {
            case Geofire.onKeyEntered:
              NearbyDriver nearbyDriver = NearbyDriver();
              nearbyDriver.key = map['key'];
              nearbyDriver.latitude = map['latitude'];
              nearbyDriver.longitude = map['longitude'];

              FireHelper.nearbyDriverList.add(nearbyDriver);

              if (nearbyDriversKeysLoaded) {
                //updateDriversOnMap();
              }
              break;

            case Geofire.onKeyExited:
              FireHelper.removeFromList(map['key']);
              //updateDriversOnMap();
              break;

            case Geofire.onKeyMoved:
            // Update your key's location
              NearbyDriver nearbyDriver = NearbyDriver();
              nearbyDriver.key = map['key'];
              nearbyDriver.latitude = map['latitude'];
              nearbyDriver.longitude = map['longitude'];

              FireHelper.updateNearbyLocation(nearbyDriver);
              //updateDriversOnMap();
              break;

            case Geofire.onGeoQueryReady:
            // All Intial Data is loaded

              print('firehelper length: ${FireHelper.nearbyDriverList.length}');
              nearbyDriversKeysLoaded = true;
              //updateDriversOnMap();
              break;
          }
        }
      });
    }
  }