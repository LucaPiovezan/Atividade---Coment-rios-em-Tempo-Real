import 'package:flutter/foundation.dart';

import '../models/comentario.dart';
import '../services/comentario_service.dart';

class ComentarioProvider extends ChangeNotifier {
  ComentarioProvider(this._service);

  final ComentarioService _service;

  bool _enviando = false;
  bool _excluindo = false;
  String? _erro;

  bool get enviando => _enviando;
  bool get excluindo => _excluindo;
  String? get erro => _erro;

  Future<bool> enviar(String publicacaoId, String texto) async {
    if (texto.trim().isEmpty) return false;
    _enviando = true;
    _erro = null;
    notifyListeners();
    try {
      await _service.enviar(publicacaoId: publicacaoId, texto: texto);
      return true;
    } catch (e) {
      _erro = 'Não foi possível enviar o comentário: $e';
      return false;
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  Future<bool> excluir(Comentario comentario) async {
    _excluindo = true;
    _erro = null;
    notifyListeners();
    try {
      await _service.excluir(comentario);
      return true;
    } catch (e) {
      _erro = 'Não foi possível excluir: $e';
      return false;
    } finally {
      _excluindo = false;
      notifyListeners();
    }
  }
}
