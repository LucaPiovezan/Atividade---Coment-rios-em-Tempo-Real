import 'package:atividadecomentariosemtemporeal/models/comentario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Comentario', () {
    test('constrói o comentário com os campos guardados no Firestore', () {
      final comentario = Comentario.fromMap('c1', {
        'texto': 'Eu prefiro jogos de aventura!',
        'autorNome': 'Maria',
        'autorId': 'uid-maria',
        'publicacaoId': 'p1',
        'data': Timestamp.fromDate(DateTime(2026, 10, 19, 12)),
      });

      expect(comentario.id, 'c1');
      expect(comentario.texto, 'Eu prefiro jogos de aventura!');
      expect(comentario.autorNome, 'Maria');
      expect(comentario.autorId, 'uid-maria');
      expect(comentario.publicacaoId, 'p1');
      expect(comentario.data, DateTime(2026, 10, 19, 12));
    });

    test('usa valores padrão quando os campos não existem', () {
      final comentario = Comentario.fromMap('c2', const {});

      expect(comentario.texto, '');
      expect(comentario.autorNome, 'Usuário');
      expect(comentario.autorId, '');
      expect(comentario.publicacaoId, '');
      expect(comentario.data, isNull);
    });

    test('cada comentário fica ligado apenas à sua publicação', () {
      final primeira = Comentario.fromMap('c1', {'publicacaoId': 'p1'});
      final segunda = Comentario.fromMap('c2', {'publicacaoId': 'p2'});

      expect(primeira.publicacaoId, 'p1');
      expect(segunda.publicacaoId, 'p2');
      expect(primeira.publicacaoId, isNot(segunda.publicacaoId));
    });
  });

  group('formatarData', () {
    test('mostra "agora" para comentário muito recente', () {
      expect(formatarData(DateTime.now()), 'agora');
    });

    test('mostra os minutos quando o comentário tem menos de uma hora', () {
      final data = DateTime.now().subtract(const Duration(minutes: 25));
      expect(formatarData(data), 'há 25 min');
    });

    test('mostra as horas quando o comentário tem menos de um dia', () {
      final data = DateTime.now().subtract(const Duration(hours: 3));
      expect(formatarData(data), 'há 3 h');
    });

    test('mostra dia/mês e hora para o mesmo ano', () {
      final data = DateTime.now().subtract(const Duration(days: 10));
      final esperado = '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')} '
          '${data.hour.toString().padLeft(2, '0')}:'
          '${data.minute.toString().padLeft(2, '0')}';
      expect(formatarData(data), esperado);
    });

    test('devolve texto vazio quando não há data', () {
      expect(formatarData(null), '');
    });
  });
}
