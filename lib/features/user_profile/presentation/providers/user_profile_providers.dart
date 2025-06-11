import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/user_profile/data/datasources/firestore_user_profile_datasource.dart';
import 'package:mobile_app_project_bookstore/features/user_profile/data/repositories/user_profile_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/user_profile/domain/repositories/user_profile_repository.dart';

// Provider for the user profile datasource
final userProfileDataSourceProvider = Provider<FirestoreUserProfileDataSource>((ref) {
  return FirestoreUserProfileDataSource(FirebaseFirestore.instance);
});

// Provider for the user profile repository
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final dataSource = ref.watch(userProfileDataSourceProvider);
  return UserProfileRepositoryImpl(dataSource: dataSource);
});

// This provider exposes the createUserProfile function for the auth notifier to use.
final createUserProfileProvider = Provider((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return repository.createUserProfile;
});
