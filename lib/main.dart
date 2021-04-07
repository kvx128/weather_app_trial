import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MaterialApp(
      home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static double lat = 0;
  static double long = 0;
  bool isLoading = false;
  WeatherData weatherData;
  String cityName;
  String countryName;
  String error;
  Location _location;


  Future<WeatherData> loadWeather() async {
    setState(() {
      isLoading = true;
    });

    final String url = "https://api.openweathermap.org/data/2.5/weather?lat=${lat.toString()}&lon=${long.toString()}&appid=c338b6ce031b8c44b052731c6f954ad4";
    print(url);
    final weatherResponse = await http.get(Uri.dataFromString(url));


    if (weatherResponse.statusCode == 200) {
      setState(() {
        weatherData =
        new WeatherData.fromJson(jsonDecode(weatherResponse.body));
        isLoading = false;
      });
      return weatherData;
    }

    setState(() {
      isLoading = false;
    });

    return null;
  }

  nameToLatLong() async{
    String name = cityName + " ," + countryName;
    isLoading = false;
    var addresses = await Geocoder.local.findAddressesFromQuery(name);
    var first = addresses.first;
    print("${first.featureName} : ${first.coordinates}");
    setState(() {
      long = first.coordinates.longitude;
      lat = first.coordinates.latitude;
      print("$lat $long");
    });
  }

  getCurrentLocation () async {
    Map<String, double> location;

    try {
      location = (_location.getLocation) as Map<String, double>;

      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
        'Permission denied - please ask the user to enable it from the app settings';
      }

    }

    if (location != null) {
      setState(() {
        lat = location['latitude'];
        long = location['longitude'];
      });
    }
  }

  // Future <void> getCurrentLocation () async {
  //   bool isServiceEnabled;
  //   LocationPermission permission;
  //   isServiceEnabled = await Geolocator.isLocationServiceEnabled();
  //
  //   if(!isServiceEnabled)
  //     return Future.error('Location Services are Disabled');
  //
  //   permission = await Geolocator.checkPermission();
  //
  //   if(permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.deniedForever)
  //       return Future.error('Location permissions are permanently denied');
  //     if (permission == LocationPermission.denied)
  //       return Future.error('Location permissions are denied');
  //   }
  //   _location = await Geolocator.getCurrentPosition();
  //
  //   setState(() {
  //     lat =  _location.latitude;
  //     long = _location.longitude;
  //     print("current loc $lat , $long");
  //   });
  //
  // }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Weather',
        theme: ThemeData(
          primarySwatch: Colors.lightGreen,
        ),
        home: Scaffold(
          backgroundColor: Colors.lightGreenAccent,
          appBar: AppBar(
            title: Text("Waether Now"),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    hintText: 'Enter City Name',
                    labelText: 'City Name'
                ),
                onChanged: (value) {
                  setState(() {
                    cityName = value.toLowerCase();
                  });
                },
              ),
              TextFormField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      hintText: 'Enter Country Name',
                      labelText: 'Country Name'
                  ),
                  onChanged: (value) {
                    setState(() {
                      countryName = value.toLowerCase();
                    });
                  }
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    getCurrentLocation();
                    loadWeather();
                    nameToLatLong();
                    loadWeather();
                    while(weatherData.name != null )
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Page2(weather: weatherData) ));
                  },
                  child: Text('Fetch Data'),
                ),
              )
            ],
          ),
        ),
      );
    }
}

class WeatherData {
  final DateTime date;
  final String name;
  final double temp;
  final String main;

  WeatherData({this.date, this.name, this.temp, this.main});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      date: new DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: false),
      name: json['name'],
      temp: json['main']['temp'].toDouble(),
      main: json['weather']['main'],
    );
  }
}

class Page2 extends StatelessWidget {
  final WeatherData weather;

  const Page2({Key key, this.weather}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Weather Now"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(weather.name, style: new TextStyle(color: Colors.black)),
            Text(weather.main, style: new TextStyle(color: Colors.black, fontSize: 24.0)),
            Text('${weather.temp.toString()}°F',  style: new TextStyle(color: Colors.black)),
            Text(new DateFormat.yMMMd().format(weather.date), style: new TextStyle(color: Colors.black)),
            Text(new DateFormat.Hm().format(weather.date), style: new TextStyle(color: Colors.black)),
            ElevatedButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("Go BAck"))
          ],
        ),
      ),
    );
  }
}
