// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mta/core/error/failures.dart';
// import 'package:mta/core/utils/constants.dart';
// import 'package:mta/features/users/data/models/user_model.dart';

// abstract class UserRemoteDataSource {
//   Future<List<UserModel>> getUsers();
//   Future<UserModel> createUser(UserModel user);
//   Future<UserModel> updateUser(UserModel user);
//   Future<void> deleteUser(String userId);
// }

// class UserRemoteDataSourceImpl implements UserRemoteDataSource {
//   final FirebaseFirestore firestore;

//   UserRemoteDataSourceImpl({required this.firestore});

//   @override
//   Future<List<UserModel>> getUsers() async {
//     try {
//       final snapshot = await firestore
//           .collection(AppConstants.collectionUsers)
//           .orderBy('createdAt', descending: false)
//           .get();
//       return snapshot.docs
//           .map((doc) => UserModel.fromJson(doc.data()))
//           .toList();
//     } catch (e) {
//       throw ServerFailure(e.toString());
//     }
//   }

//   @override
//   Future<UserModel> createUser(UserModel user) async {
//     try {
//       await firestore
//           .collection(AppConstants.collectionUsers)
//           .doc(user.id)
//           .set(user.toJson());
//       return user;
//     } catch (e) {
//       throw ServerFailure(e.toString());
//     }
//   }

//   @override
//   Future<UserModel> updateUser(UserModel user) async {
//     try {
//       await firestore
//           .collection(AppConstants.collectionUsers)
//           .doc(user.id)
//           .update(user.toJson());
//       return user;
//     } catch (e) {
//       throw ServerFailure(e.toString());
//     }
//   }

//   @override
//   Future<void> deleteUser(String userId) async {
//     try {
//       await firestore
//           .collection(AppConstants.collectionUsers)
//           .doc(userId)
//           .delete();
//     } catch (e) {
//       throw ServerFailure(e.toString());
//     }
//   }
// }
