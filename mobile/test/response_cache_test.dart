import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petly/data/api/api_client.dart';
import 'package:petly/data/repositories/stores_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stubs [ApiClient.get] so tests can control the response/error without any
/// real network I/O — the rest of [ApiClient] (refresh locking, auth header
/// injection, etc) is irrelevant to the cache-aside behavior under test.
class _FakeApiClient extends ApiClient {
  _FakeApiClient();

  bool shouldFail = false;
  int callCount = 0;

  static const _storeJson = {
    'id': 'store-1',
    'name': 'Test Pet Store',
    'type': 'Pet Store',
    'location': 'Beirut',
    'featured': false,
    'is_open_now': true,
  };

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    callCount++;
    if (shouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionError,
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: [_storeJson] as T,
    );
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test(
    'falls back to the last cached response on a connectivity error',
    () async {
      final api = _FakeApiClient();
      final repo = StoresRepository(api);

      // First call succeeds over the network and populates the cache.
      final firstResult = await repo.list();
      expect(firstResult, hasLength(1));
      expect(firstResult.first.name, 'Test Pet Store');
      expect(api.callCount, 1);

      // Second call fails with a connectivity-class DioException — the
      // repository should return the cached data instead of throwing.
      api.shouldFail = true;
      final secondResult = await repo.list();
      expect(secondResult, hasLength(1));
      expect(secondResult.first.name, 'Test Pet Store');
      expect(api.callCount, 2);
    },
  );

  test(
    'rethrows a connectivity error when nothing is cached yet',
    () async {
      final api = _FakeApiClient()..shouldFail = true;
      final repo = StoresRepository(api);

      await expectLater(repo.list(), throwsA(isA<DioException>()));
    },
  );

  test(
    'rethrows non-connectivity errors even if a cached response exists',
    () async {
      final api = _FakeApiClient();
      final repo = StoresRepository(api);

      final firstResult = await repo.list();
      expect(firstResult, hasLength(1));

      // A bad-response error (e.g. a real 500) should not be masked by the
      // cache fallback — only connectivity-class failures fall back.
      api.shouldFail = true;
      final badResponseApi = _BadResponseApiClient();
      final repoWithBadResponse = StoresRepository(badResponseApi);
      await expectLater(
        repoWithBadResponse.list(),
        throwsA(isA<DioException>()),
      );
    },
  );
}

class _BadResponseApiClient extends ApiClient {
  _BadResponseApiClient();

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 500,
      ),
    );
  }
}
