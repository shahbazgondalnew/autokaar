import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CarModel {
  final String name;
  final String imageUrl;

  CarModel({required this.name, required this.imageUrl});
}

class CarGridScreen extends StatelessWidget {
  List<CarModel> carModels = [
    CarModel(
      name: 'Sazuki',
      imageUrl:
          'https://logos-world.net/wp-content/uploads/2021/10/Suzuki-Logo.png',
    ),
    CarModel(
      name: 'Honda',
      imageUrl:
          'https://logos-world.net/wp-content/uploads/2021/03/Honda-Logo.png',
    ),
    // Add more CarModel instances for other cars
    // ...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Grid'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: carModels.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CarDetailsScreen(carModel: carModels[index]),
                    ),
                  );
                },
                child: GridTile(
                  child: Image.network(
                    carModels[index].imageUrl,
                    fit: BoxFit.cover,
                  ),
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    title: Text(
                      carModels[index].name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CarDetailsScreen extends StatelessWidget {
  final CarModel carModel;

  CarDetailsScreen({required this.carModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Details'),
      ),
      body: Center(
        child: Text(
          carModel.name,
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
