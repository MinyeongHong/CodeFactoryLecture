import 'package:api_example/restaurant/component/restaurant_card.dart';
import 'package:api_example/restaurant/model/restaurant_model.dart';
import 'package:api_example/restaurant/repository/restaurant_repository.dart';
import 'package:api_example/restaurant/view/restaurant_detail_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/const/data.dart';
import '../../common/dio/dio.dart';
import '../component/restaurant_card.dart';

class RestaurantScreen extends ConsumerWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  Future<List<RestaurantModel>> paginateRestaurant(WidgetRef ref) async {
    final dio = ref.watch(dioProvider);
    final resp = await RestaurantRepository(dio,baseUrl: 'http://$ip/restaurant').paginate();
    return resp.data;
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List<RestaurantModel>>(
            future: paginateRestaurant(ref),
            builder: (context, AsyncSnapshot<List<RestaurantModel>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.separated(
                  itemBuilder: (_, index) {
                    final pItem = snapshot.data![index];
                   // final pItem = RestaurantModel.fromJson(item);

                    return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RestaurantDetailScreen(
                                id: pItem.id,
                              ),
                            ),
                          );
                        },
                        child: RestaurantCard.fromModel(model: pItem));
                  },
                  separatorBuilder: (_, index) => const SizedBox(height: 16),
                  itemCount: snapshot.data!.length);
            },
          ),
        ),
      ),
    );
  }
}
