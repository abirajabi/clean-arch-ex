import 'dart:convert';

import 'package:clean_arch_tdd/core/error/exceptions.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';

import '../../../../core/fixtures/fixture_reader.dart';
import 'number_trivia_local_datasource_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));

    test(
        'should return NumberTrivia from cached when there is one in the cache',
        () async {
      when(mockSharedPreferences.getString(any))
          .thenReturn(fixture('trivia_cached.json'));
      final result = await dataSource.getLastNumberTrivia();
      verify(mockSharedPreferences.getString(cachedNumberTrivia));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw CacheException when there is no cached value', () async {
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      final call = dataSource.getLastNumberTrivia;
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'Test trivia');

    test('should call sharedPreferences to cache the data', () async {
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      dataSource.cacheLastNumberTrivia(tNumberTriviaModel);
      final expectedJsonString = jsonEncode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(
          cachedNumberTrivia, expectedJsonString));
    });
  });
}
