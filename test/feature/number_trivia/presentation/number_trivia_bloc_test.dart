import 'package:clean_arch_tdd/core/error/failures.dart';
import 'package:clean_arch_tdd/core/usecases/usecase.dart';
import 'package:clean_arch_tdd/core/utils/input_converter.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_arch_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, InputConverter, GetRandomNumberTrivia])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initial state of bloc should be Empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(text: 'Test trivia', number: 1);

    setUpMockInputConverterSuccess() {
      when(mockInputConverter.stringToUnsignedInt(any))
          .thenReturn(const Right(tNumberParsed));
    }

    test(
        'should call the InputConverter and convert the string to an unsigned integer',
        () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      bloc.add(const GetTriviaForConcreteNumber(numberString: tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInt(any));
      verify(mockInputConverter.stringToUnsignedInt(tNumberString));
    });

    test('should emit [Error] state when the input is invalid', () async {
      when(mockInputConverter.stringToUnsignedInt(any))
          .thenReturn(Left(InvalidInputFailure()));
      final expectedStream = [const Error(message: invalidInputFailureMessage)];
      expectLater(bloc.stream, emitsInOrder(expectedStream));
      bloc.add(const GetTriviaForConcreteNumber(numberString: tNumberString));
    });

    test('should get data from the concrete use case', () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      bloc.add(const GetTriviaForConcreteNumber(numberString: tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      verify(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully', () {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      final expectedStream = [
        Loading(),
        const Loaded(numberTrivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStream));
      bloc.add(const GetTriviaForConcreteNumber(numberString: tNumberString));
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      final expectedStream = [
        Loading(),
        const Error(message: serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStream));
      bloc.add(const GetTriviaForConcreteNumber(numberString: tNumberString));
    });

    test(
        'should emit [Loading, Error] with a proper message when getting data fails',
        () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      final expectedStream = [
        Loading(),
        const Error(message: cacheFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStream));
      bloc.add(const GetTriviaForConcreteNumber(numberString: tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(text: 'Test trivia', number: 1);

    test(
      'should get data from the random use case',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        // act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(mockGetRandomNumberTrivia(any));
        // assert
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test('should emit [Loading, Loaded] when data is gotten successfully', () {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      final expectedStream = [
        Loading(),
        const Loaded(numberTrivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStream));
      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      final expectedStream = [
        Loading(),
        const Error(message: serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStream));
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'should emit [Loading, Error] with a proper message when getting data fails',
        () async {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      final expectedStream = [
        Loading(),
        const Error(message: cacheFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStream));
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
