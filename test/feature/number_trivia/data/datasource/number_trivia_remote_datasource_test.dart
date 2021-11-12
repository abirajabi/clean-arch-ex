import 'dart:convert';

import 'package:clean_arch_tdd/core/error/exceptions.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import '../../../../core/fixtures/fixture_reader.dart';
import 'number_trivia_remote_datasource_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late NumberTriviaRemoteDataSourceImplementation dataSource;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    dataSource =
        NumberTriviaRemoteDataSourceImplementation(httpClient: mockClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong.', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

    test(
        'should perform a GET request on a URL with number being the endpoint and with application/json header',
        () {
      setUpMockHttpClientSuccess200();
      dataSource.getConcreteNumberTrivia(tNumber);
      verify(mockClient.get(
        Uri.parse(
          'http://numbersapi.com/$tNumber',
        ),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should return NumberTrivia when response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess200();
      final response = await dataSource.getConcreteNumberTrivia(tNumber);
      expect(response, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when response code is 404 or other',
        () async {
      setUpMockHttpClientFailure404();
      final call = dataSource.getConcreteNumberTrivia;
      expect(call(tNumber), throwsA(isA<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

    test(
        'should perform a GET request on a  URL with *random* endpoint with application/json header',
        () {
      setUpMockHttpClientSuccess200();
      dataSource.getRandomNumberTrivia();
      verify(mockClient.get(
        Uri.parse('http://numbersapi.com/random'),
        headers: {'Content-Type': 'application/json'},
      ));
    });

    test('should return a NUmberTriviaModel when success (200)', () async {
      setUpMockHttpClientSuccess200();
      final results = await dataSource.getRandomNumberTrivia();
      expect(results, equals(tNumberTriviaModel));
    });

    test('should return ServerException when response code is 404 or other',
        () {
      setUpMockHttpClientFailure404();
      final call = dataSource.getRandomNumberTrivia;
      expect(() => call(), throwsA(isA<ServerException>()));
    });
  });
}
