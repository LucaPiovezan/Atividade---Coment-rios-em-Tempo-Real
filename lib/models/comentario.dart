import 'package:cloud_firestore/cloud_firestore.dart';

class Comentario {
  final String id;
  final String texto;
  final String autorNome;
  final String autorId;
  final String publicacaoId;
  final DateTime? data;

  const Comentario({
    required this.id,
    required this.texto,
    required this.autorNome,
    required this.autorId,
    required this.publicacaoId,
    this.data,
  });

  factory Comentario.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Comentario.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  factory Comentario.fromMap(String id, Map<String, dynamic> dados) {
    return Comentario(
      id: id,
      texto: (dados['texto'] as String?) ?? '',
      autorNome: (dados['autorNome'] as String?) ?? 'Usuário',
      autorId: (dados['autorId'] as String?) ?? '',
      publicacaoId: (dados['publicacaoId'] as String?) ?? '',
      data: (dados['data'] as Timestamp?)?.toDate(),
    );
  }
}

String formatarData(DateTime? data) {
  if (data == null) return '';
  final local = data.toLocal();
  final agora = DateTime.now();
  final diff = agora.difference(local);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inHours < 1) return 'há ${diff.inMinutes} min';
  if (diff.inDays < 1) return 'há ${diff.inHours} h';
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  if (local.year == agora.year) {
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia/$mes $hora:$minuto';
  }
  return '$dia/$mes/${local.year}';
}
