import 'dart:async';
import 'dart:io';
import 'package:agrii_ransport/add_widget/NavButton.dart';
import 'package:agrii_ransport/add_widget/progressIndicator.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class MapView extends StatefulWidget {

  static const String id = 'MapView()';


  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView>  with TickerProviderStateMixin{

  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  Position _currentPosition;
  String _currentAddress;

  double searchSheetHeight = (Platform.isIOS) ? 160 : 160;
  double rideDetailsSheetHeight = 0 ;
  double requestingSheetHeight = 0;
  double mapBottomPadding = 0;
  bool drawerCanOpen = true;
  Timer timer;


  DatabaseReference requestDatabase;

  void showDetailsSheet () async
  {

    setState(() {

      rideDetailsSheetHeight =(Platform.isAndroid) ? 235  : 260 ;
      mapBottomPadding = (Platform.isAndroid) ?  240 : 230 ;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheet()
  {

    setState(()
    {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 240 : 260;
      mapBottomPadding = (Platform.isAndroid) ? 200: 190;
      drawerCanOpen =true;
    });
       createRideRequest();  ///  request to database
  }

  void setupPositionLocator() async
  {

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation,);
    _currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom:18);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

  }

  String accountStatus = '******';
  User mCurrentUser;
  FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _getCurrentLocation();
    _getCurrentUser();
    print('here outside async');

  }

  _getCurrentUser () async {
    mCurrentUser = await _auth.currentUser;
    print('Hello ' + mCurrentUser.displayName.toString());
    setState(() {
      // ignore: unnecessary_statements
      mCurrentUser != null ? accountStatus = 'Signed In' : 'Not Signed In';
    });
  }

  void createRideRequest()
  {
    requestDatabase = FirebaseDatabase.instance.reference().child('tripRequest').push();

    Map pickupMap =
    {
      'latitide': _currentPosition.latitude.toString(),
      'longitude' : _currentPosition.longitude.toString(),
    };

    Map destinationMap =
    {
    };

     Map rideMap =
     {
        'created_at' : DateTime.now().toString(),
        'pickup_address' : _startAddress ,
        'destination_address' : _destinationAddress ,
        'location': pickupMap,
        'destination': destinationMap,
        'payment_method': 'card',
        'driver_id': 'waiting',
     };

     requestDatabase.set(rideMap);

  }


  void cancelRequest()
  {
    requestDatabase.remove();
  }


  launchMap() async
  {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$_currentPosition.latitude,$_currentPosition.longitude";

    if (await canLaunch(googleMapsUrl))
      {
         await launch(googleMapsUrl);
      }
    else
      {
        throw "Couldn't launch URL";
      }
  }

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(

          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
          setState(() {

           _currentPosition = position;
            print('CURRENT POS: $_currentPosition');
            mapController.animateCamera(

            CameraUpdate.newCameraPosition(
                  CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                   zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p =
      await placemarkFromCoordinates(_currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark = await locationFromAddress(_destinationAddress);

      if (startPlacemark != null && destinationPlacemark != null) {
        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(latitude: _currentPosition.latitude, longitude: _currentPosition.longitude, speed: null, heading: null ,accuracy: null,altitude: null, timestamp: null,speedAccuracy: null)
            : Position(latitude: startPlacemark[0].latitude, longitude: startPlacemark[0].longitude, speed: null, heading: null ,accuracy: null,altitude: null, timestamp: null,speedAccuracy: null);
        Position destinationCoordinates =  Position(
            latitude: destinationPlacemark[0].latitude,
            longitude: destinationPlacemark[0].longitude,
            speed: null, heading: null ,accuracy: null,altitude: null, timestamp: null,speedAccuracy: null);

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that the position relative
        // to the frame, and pan & zoom the camera accordingly.
        double miny = (startCoordinates.latitude <= destinationCoordinates.latitude)
            ? startCoordinates.latitude
            : destinationCoordinates.latitude;
        double minx = (startCoordinates.longitude <= destinationCoordinates.longitude)
            ? startCoordinates.longitude
            : destinationCoordinates.longitude;
        double maxy = (startCoordinates.latitude <= destinationCoordinates.latitude)
            ? destinationCoordinates.latitude
            : startCoordinates.latitude;
        double maxx = (startCoordinates.longitude <= destinationCoordinates.longitude)
            ? destinationCoordinates.longitude
            : startCoordinates.longitude;

        _southwestCoordinates = Position(latitude: miny, longitude: minx, speed: null, heading: null ,accuracy: null,altitude: null, timestamp: null,speedAccuracy: null);
        _northeastCoordinates = Position(latitude: maxy, longitude: maxx, speed: null, heading: null ,accuracy: null,altitude: null, timestamp: null,speedAccuracy: null);

        // Accommodate the two locations within the
        // camera view of the map
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        return true;
      }
    }
     catch (e)
     {
       print(e);
     }
    return false;
  }



  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: markers != null ? Set<Marker>.from(markers) : null,
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              compassEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {

                mapController = controller;
                setupPositionLocator();
              },
            ),

            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    ClipOval(
                      child: Material(
                        color: Colors.white, // button color
                        child: InkWell(
                          splashColor: Colors.yellowAccent, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    ClipOval(
                      child: Material(
                        color: Colors.white, // button color
                        child: InkWell(
                          splashColor: Colors.yellowAccent, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(

                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(

                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Places',
                            style: TextStyle(fontSize: 20.0),
                          ),

                          SizedBox(height: 10),

                          _textField(
                              label: 'Start',
                              hint: 'Choose starting point',
                              prefixIcon: Icon(Icons.location_on_rounded),

                              controller: startAddressController,
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {

                                setState(() {
                                  _startAddress = value;
                                });
                              }),

                          SizedBox(height: 10),
                          _textField(
                              label: 'Destination',
                              hint: 'Choose destination',
                              prefixIcon: Icon(Icons.add_location_alt_rounded),
                              controller: destinationAddressController,
                              focusNode: destinationAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {

                                       setState(()
                                    {
                                      _destinationAddress = value;
                                    }
                                  );
                                }
                              ),

                          SizedBox(height: 10),

                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(

                              'Ready To GO',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),

                          // ignore: deprecated_member_use
                          RaisedButton(
                            onPressed: (_startAddress != '' && _destinationAddress != '')
                                ? () async
                            {
                              startAddressFocusNode.unfocus();
                              destinationAddressFocusNode.unfocus();


                              _calculateDistance().then((isCalculated) {
                                if (isCalculated)
                                {
                                     ScaffoldMessenger.of(context).showSnackBar(

                                   SnackBar
                                     (
                                          content: Text('Trip Planned Sucessfully'),
                                     ),
                                  );
                                }
                                else
                                  {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar
                                          (
                                          content: Text('Please try again...'),
                                      ),
                                     );
                                   }
                                 }
                               );
                             }
                                : null,
                            color: Colors.yellow,

                            shape: RoundedRectangleBorder
                              (
                                  borderRadius: BorderRadius.circular(20.0),
                              ),

                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                 'Show Route'.toUpperCase(),
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 14.0),
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
                        onTap: ()
                        {
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

            // Button to navigate to homesceen
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left:2.0, top: 55),
                child: ClipOval(
                  child: Material(
                    color: Colors.white, // button color
                    child: InkWell(
                      splashColor: Colors.yellowAccent, // inkwell color
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(Icons.arrow_back_outlined),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              )
            ),

            // Button to navigate nect screen
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 85.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.yellowAccent, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.arrow_forward_outlined),
                        ),
                        onTap: () {
                           showDetailsSheet();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // TripDetails Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,

              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 150),
                child: Container(
                  decoration: BoxDecoration(
                    color:  Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red,
                        blurRadius: 15.0, // softening the shadow
                        spreadRadius: 0.5, // shadow extend
                        offset: Offset(
                          0.7,  // Move to right  horizontally
                          0.7, // Move to bottom vertically
                        ),
                      ),
                    ],
                  ),
                  height: rideDetailsSheetHeight,
                  child: Padding(
                    padding:  EdgeInsets.symmetric(vertical:18.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          color: Colors.yellow,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal :16.0),
                            child: Row(
                              children: <Widget>[
                                Image.asset('images/Truck.png',height:  70, width: 70,),
                                SizedBox(width: 16,),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Vehicle 5 TON 60Rs Per KM', style: TextStyle(fontSize:  18, fontFamily: 'Brand-Bold'),),

                                  ],
                                ),

                                Expanded(child: Container()),

                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 22,),

                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal:16.0),
                          child: Row(
                            children: <Widget>[

                              Icon(FontAwesomeIcons.moneyBillAlt, size: 18, color: Colors.black,),
                              SizedBox(width: 16,),
                              Text('Cash'),
                              SizedBox(width: 5,),
                              Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 16),

                            ],
                          ),
                        ),

                        SizedBox(height: 22,),


                        Padding(
                          padding: EdgeInsets.symmetric(horizontal:16.0),
                          child: NavButton(
                              title: 'REQUEST VEHICLE',
                              color: Colors.yellowAccent,
                              onPressed:(){
                                showRequestingSheet();
                                timer = Timer.periodic(Duration(seconds: 4),(timer) {
                                  ProgressDialog(status: 'Arranging a Vehicle',);
                                });
                              }

                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Trip Process and Cancel Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,

              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                curve: Curves.bounceInOut,

                child: Container(
                  decoration: BoxDecoration(
                    color:  Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red,
                        blurRadius: 15.0, // softening the shadow
                        spreadRadius: 0.5, // shadow extend
                        offset: Offset(
                          0.7,  // Move to right horizontally
                          0.7, // Move to bottom  vertically
                        ),
                      ),
                    ],
                  ),
                  height:  requestingSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal : 24 , vertical:  18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: <Widget>[
                        SizedBox(height: 20,),


                        SizedBox(
                          width: double.infinity,
                          child: TextLiquidFill(
                            text: 'ARRANGING A VEHICLE',
                            waveColor: Colors.black,
                            boxBackgroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontSize: 22.0,
                              fontFamily: 'Brand-Bold',
                              fontWeight: FontWeight.bold,
                            ),
                            boxHeight: 40,

                          ),
                        ),

                        SizedBox(height: 14,),

                        Row(
                          children: [
                            GestureDetector(
                              onTap: (){
                                cancelRequest();
                                resetApp();
                              },
                              child: Container(
                               // alignment: Alignment.centerLeft,
                                height: 50,
                                width: 170,
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent,
                                  borderRadius: BorderRadius.circular(25),
                                  border:  Border.all(width: 1.0 , color: Colors.white54),
                                ),
                                child: Icon(Icons.close , size: 35, color: Colors.redAccent,
                                ),

                              ),
                            ),
                            SizedBox(width: 4,),

                            GestureDetector(
                              onTap: (){
                              launchMap();
                              },
                              child: Container(
                               // alignment:  Alignment.centerRight,
                                height: 50,
                                width: 170,
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent,
                                  borderRadius: BorderRadius.circular(25),
                                  border:  Border.all(width: 1.0 , color: Colors.white54),
                                ),
                                child: Icon(Icons.navigation , size: 35, color: Colors.redAccent,

                                ),
                              ),
                            ),
                          ],
                        ),


                        SizedBox(height: 10, ),

                        Row(
                          children: [
                            Container(
                             // width: double.infinity,
                              child: Text(
                                'Cancel Vehicle',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),

                            SizedBox(width: 80,),

                            Container(
                              //  width: double.infinity,
                              child: Text(
                                'Direction',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void resetApp() {
    setState(() {

      markers.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      searchSheetHeight = (Platform.isAndroid) ? 160 : 160;
      mapBottomPadding = (Platform.isAndroid)? 280 : 270;
      drawerCanOpen = true;

       setupPositionLocator();
      }
    );
  }
}

class Var
{
  static const API_KEY = 'AIzaSyD5NuKqAzz2qlyqZq_sJ5ZXQeWAjgFl4Bk';
}






