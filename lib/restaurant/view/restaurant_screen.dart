링import 'package:api_example/restaurant/component/restaurant_card.dart';
import 'package:api_example/restaurant/model/restaurant_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/const/data.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  Future<List> paginateRestaurant() async {
    final dio = Dio();
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final resp = await dio.get('http://$ip/restaurant',
        options: Options(headers: {
          'authorization': 'Bearer $accessToken',
        }));

    return resp.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List>(
            future: paginateRestaurant(),
            builder: (context, AsyncSnapshot<List> snapshot) {
              if(!snapshot.hasData) return SizedBox();

              return ListView.separated(
                  itemBuilder: (_, index) {
                    final item = snapshot.data![index];
                    final pItem = RestaurantModel.fromJson(json: item);

                    return RestaurantCard.fromModel(model: pItem);
                  },
                  separatorBuilder: (_, index) => SizedBox(height: 16),
                  itemCount: snapshot.data!.length);
            },
          ),
        ),
      ),
    );
  }
}
