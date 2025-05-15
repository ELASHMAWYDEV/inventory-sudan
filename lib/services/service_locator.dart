import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:inventory_sudan/data/repositories/firebase_repository_impl.dart';
import 'package:inventory_sudan/domain/repositories/data_repository.dart';
import 'package:inventory_sudan/domain/services/data_service.dart';
import 'package:inventory_sudan/services/firebase_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Initialize Firebase Service
  final firebaseService = FirebaseService();
  await firebaseService.initializeFirebase();
  serviceLocator.registerSingleton<FirebaseService>(firebaseService);

  // Register repository
  serviceLocator.registerLazySingleton<DataRepository>(
    () => FirebaseRepositoryImpl(),
  );

  // Register services
  serviceLocator.registerLazySingleton<DataService>(
    () => DataService(serviceLocator<DataRepository>()),
  );
}
