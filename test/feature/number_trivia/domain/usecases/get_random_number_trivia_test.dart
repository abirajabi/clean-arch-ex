import 'package:clean_arch_tdd/core/usecases/usecase.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_concrete_number_trivia_test.mocks.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

@GenerateMocks([MockNumberTriviaRepository])
void main() {
  MockMockNumberTriviaRepository mockNumberTriviaRepository =
      MockMockNumberTriviaRepository();
  GetRandomNumberTrivia usecase =
      GetRandomNumberTrivia(numberTriviaRepository: mockNumberTriviaRepository);

  setUp(() {
    mockNumberTriviaRepository = MockMockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(
        numberTriviaRepository: mockNumberTriviaRepository);
  });

  const tNumberTrivia = NumberTrivia(text: 'test', number: 1);

  test('Should get trivia from repository', () async {
    when(mockNumberTriviaRepository.getRandomNumberTrivia())
        .thenAnswer((_) async => const Right(tNumberTrivia));

    final results = await usecase(NoParams());
    expect(results, const Right(tNumberTrivia));

    verify(mockNumberTriviaRepository.getRandomNumberTrivia());
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
