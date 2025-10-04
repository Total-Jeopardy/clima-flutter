import 'package:clima/screens/city_screen.dart';
import 'package:clima/services/weather.dart';
import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, required this.locationWeather});
  final dynamic locationWeather; // this must be the resolved map, not a Future

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  int? temperature;
  String weatherIcon = '';
  String? cityName;
  String? message;
  final WeatherModel weatherModel = WeatherModel();

  @override
  void initState() {
    super.initState();
    updateUI(widget.locationWeather);
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = '';
        message = 'Error in getting location';
        cityName = 'Your city';
        return;
      }
      final temp = (weatherData['main']['temp'] as num).toDouble();
      temperature = temp.toInt();
      final condition = weatherData['weather'][0]['id'] as int;
      weatherIcon = weatherModel.getWeatherIcon(condition);
      cityName = weatherData['name'] as String;
      message = weatherModel.getMessage(temperature!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/location_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () async {
                      final weatherData = await weatherModel
                          .getLocationWeather();
                      if (!mounted) return;
                      updateUI(weatherData);
                    },
                    child: const Icon(Icons.near_me, size: 50.0),
                  ),
                  TextButton(
                    onPressed: () async {
                      var typedCityName = await Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (ctx) => CityScreen()));
                      if (typedCityName != null) {
                        var weatherData = await weatherModel.getCityWeather(
                          typedCityName,
                        );
                        updateUI(weatherData);
                      }
                    },
                    child: const Icon(Icons.location_city, size: 50.0),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: <Widget>[
                    Text('${temperature ?? ''}', style: kTempTextStyle),
                    const SizedBox(width: 40),
                    Text(weatherIcon, style: kConditionTextStyle),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Text(
                  '${message ?? ''} in ${cityName ?? ''} !',
                  textAlign: TextAlign.right,
                  style: kMessageTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
