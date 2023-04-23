import 'package:api_example/common/model/cursor_pagination_model.dart';
import 'package:api_example/common/model/pagination_param.dart';
import 'package:api_example/restaurant/model/restaurant_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/restaurant_repository.dart';

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  final notifier = RestaurantStateNotifier(repository: repository);

  return notifier;
});

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    paginate();
  }

  void paginate({
    int fetchCount = 20,

    //fetchMore는 기존 데이터를 보여주며 가져오고, forceRefetch는 그냥 페이지 전체 로딩
    bool fetchMore = false, // true면 추가 데이터 가져옴, false면 새로고침 (현재 상태 덮어씌우기)
    bool forceRefetch = false, //true면 CursorPaginationLoading()
  }) async {
    try {
      final resp = await repository.paginate();
      state = resp;
      //state의 다섯가지 상태
      // 1. CursorPagination - 정상적으로 데이터가 있을 때

      // 2. CursorPaginationLoading - 데이터가 로딩중 (현재 캐시없음)

      // 3. CursorPaginationError - 에러 상태

      // 4. CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올때

      // 5. CursorPaginationFetchMore - 추가 데이터를 paginate 요청 받았을 때

      //바로 return하는 상황
      // hasMore = false (페이지네이션을 최소 한번은 한 상태)
      // 로딩 중 fetchMore = true
      // fetchMore = false -> 새로고침의 의도

      if (state is CursorPagination && !forceRefetch) {
        //정상 페이지네이션 상태
        final pState = state as CursorPagination;

        if (!pState.meta.hasMore) {
          //no more data
          return;
        }
      }

      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;

      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      //create pagination params
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      //fetch more : To get more additional data
      if (fetchMore) {
        final pState = state as CursorPagination;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );

        final resp = await repository.paginate(
          paginationParams: paginationParams,
        );

        if (state is CursorPaginationFetchingMore) {
          final pState = state as CursorPaginationFetchingMore;

          //기존 데이터에 새 데이터 추가
          state = resp.copyWith(data: [
            ...pState.data,
            ...resp.data,
          ]);
        } else {
          state = resp;
        }
      } else {
        //만약 데이터가 있는 상황이라면 기존 데이터를 보존한 채로 fetch 요청을 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination;
          state = CursorPaginationRefetching(
            meta: pState.meta,
            data: pState.data,
          );
        } else {
          state = CursorPaginationLoading();
        }
      }
    } catch (e) {
      state = CursorPaginationError(message: 'load failed');
    }
  }
}
