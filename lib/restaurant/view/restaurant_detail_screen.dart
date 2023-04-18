import 'package:api_example/common/dio/dio.dart';
import 'package:api_example/common/layout/default_layout.dart';
import 'package:api_example/product/component/product_card.dart';
import 'package:api_example/restaurant/component/restaurant_card.dart';
import 'package:api_example/restaurant/model/restaurant_detail_model.dart';
import 'package:api_example/restaurant/repository/restaurant_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/const/data.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String id;

  const RestaurantDetailScreen({Key? key, required this.id}) : super(key: key);

  Future<RestaurantDetailModel> getRestaurantDetail() async {
    final dio = Dio();

    dio.interceptors.add(CustomInterceptor(storage: storage));

    final repository = RestaurantRepository(dio,baseUrl: 'http://$ip/restaurant');
    
    return repository.getRestaurantDetail(id: id);

    // final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    //
    // final resp = await dio.get(
    //   'http://$ip/restaurant/$id',
    //   options: Options(headers: {'authorization': 'Bearer $accessToken'}),
    // );
    // return resp.data;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: "불타는 떡볶이",
      child: FutureBuilder<RestaurantDetailModel>(
          future: getRestaurantDetail(),
          builder: (_, AsyncSnapshot<RestaurantDetailModel> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return CustomScrollView(
              slivers: [
                renderTop(model: snapshot.data!),
                renderLabel(),
                renderProducts(products: snapshot.data!.products),
              ],
            );
          }),
    );
  }

  SliverToBoxAdapter renderTop({required RestaurantDetailModel model}) {
    return SliverToBoxAdapter(
        child: RestaurantCard.fromModel(
      model: model,
      isDetail: true,
    ));
  }

  SliverPadding renderProducts(
      {required List<RestaurantProductModel> products}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ProductCard.fromModel(
              model: products[index],
            ),
          );
        }, childCount: products.length),
      ),
    );
  }

  SliverPadding renderLabel() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          '메뉴',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
