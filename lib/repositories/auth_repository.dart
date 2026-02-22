import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/user_model.dart';
import 'package:prior_list/repositories/database_repository.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  final databaseRepository = autoInjector.get<DatabaseRepository>();

  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Erro ao fazer login com email e senha: $e');
    }
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await databaseRepository.createUser(
          UserModel(id: user.uid, email: email)
        );
      }
      return user;
    } catch (e) {
      throw Exception('Erro ao registrar usuário: $e');
    }
  }

  Future<User?> signInWithGoogle() async {
    try{
    final gUser = await GoogleSignIn.instance.authenticate();
    final gAuth =  gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
      if (user != null) {
        await databaseRepository.createUser(
          UserModel(id: user.uid, name: user.displayName!, email: user.email!,)
        );
      }
    return user;
    } catch (e) {
      throw Exception('Erro ao fazer login com Google: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

}