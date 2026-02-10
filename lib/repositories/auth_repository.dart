import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Getter para escutar mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

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
      return userCredential.user;
    } catch (e) {
      throw Exception('Erro ao registrar usuário: $e');
    }
  }

  Future<User?> signInWithGoogle() async {
    try{
    final gUser = await GoogleSignIn.instance.authenticate();
    final gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
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

  User? get currentUser => _firebaseAuth.currentUser;
}