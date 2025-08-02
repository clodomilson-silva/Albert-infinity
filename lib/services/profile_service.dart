import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Atualizar perfil do usuário
  Future<void> updateUserProfile({
    required String name,
    String? phone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final userData = <String, dynamic>{
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (phone != null && phone.isNotEmpty) {
      userData['phone'] = phone;
    }

    await _firestore.collection('users').doc(user.uid).update(userData);
  }

  // Obter dados completos do usuário
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }
}
