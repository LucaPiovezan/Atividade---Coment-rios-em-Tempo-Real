import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/comentario.dart';


class ComentarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String colecao = 'comentarios';


  Stream<List<Comentario>> acompanhar(String publicacaoId) {
    return _db
        .collection(colecao)
        .where('publicacaoId', isEqualTo: publicacaoId)
        .snapshots()
        .map((snapshot) {
      final comentarios =
          snapshot.docs.map(Comentario.fromDoc).toList(growable: false);
      comentarios.sort((a, b) {
        final ta = a.data ?? DateTime.fromMillisecondsSinceEpoch(0);
        final tb = b.data ?? DateTime.fromMillisecondsSinceEpoch(0);
        return ta.compareTo(tb);
      });
      return comentarios;
    });
  }


  Future<void> enviar({
    required String publicacaoId,
    required String texto,
  }) async {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      throw Exception('Sessão expirada. Entre novamente.');
    }
    final perfil = await _db.collection('usuarios').doc(usuario.uid).get();
    final nome = (perfil.data()?['nome'] as String?) ?? 'Usuário';
    await _db.collection(colecao).add({
      'texto': texto.trim(),
      'autorNome': nome,
      'autorId': usuario.uid,
      'publicacaoId': publicacaoId,
      'data': FieldValue.serverTimestamp(),
    });
  }

  
  Future<void> excluir(Comentario comentario) async {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      throw Exception('Sessão expirada. Entre novamente.');
    }
    if (comentario.autorId != usuario.uid) {
      throw Exception('Você só pode excluir os seus próprios comentários.');
    }
    await _db.collection(colecao).doc(comentario.id).delete();
  }
}
