import 'package:clean_arch_tdd/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInt(String str) {
    try {
      final integer = int.parse(str);
      if (integer > 0) {
        return Right(int.parse(str));
      } else {
        throw const FormatException();
      }
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failure {
  @override
  List<Object?> get props => [];
}
