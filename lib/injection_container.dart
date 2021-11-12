import 'package:clean_arch_tdd/core/network/network_info.dart';
import 'package:clean_arch_tdd/core/utils/input_converter.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  //! Features
  // Bloc
  sl.registerFactory(
    () => NumberTriviaBloc(
      inputConverter: sl(),
      getConcreteNumberTrivia: sl(),
      getRandomNumberTrivia: sl(),
    ),
  );

  // Use case
  sl.registerLazySingleton(
      () => GetConcreteNumberTrivia(numberTriviaRepository: sl()));
  sl.registerLazySingleton(
      () => GetRandomNumberTrivia(numberTriviaRepository: sl()));

  //  Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Repositories
  sl.registerLazySingleton<NumberTriviaRepository>(() =>
      NumberTriviaRepositoryImplementation(
          localDataSource: sl(), remoteDataSource: sl(), networkInfo: sl()));

  //  Data sources
  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(
      () => NumberTriviaRemoteDataSourceImplementation(httpClient: sl()));
  sl.registerLazySingleton<NumberTriviaLocalDataSource>(
      () => NumberTriviaLocalDataSourceImpl(sharedPreferences: sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
}
