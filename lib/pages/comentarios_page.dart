import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comentario.dart';
import '../providers/comentario_provider.dart';
import '../services/comentario_service.dart';

class ComentariosPage extends StatefulWidget {
  const ComentariosPage({
    super.key,
    required this.publicacaoId,
    required this.autorNome,
    required this.texto,
    this.data,
  });

  final String publicacaoId;
  final String autorNome;
  final String texto;
  final DateTime? data;

  @override
  State<ComentariosPage> createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  final _comentario = TextEditingController();
  final _service = ComentarioService();
  final _foco = FocusNode();

  @override
  void dispose() {
    _comentario.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _enviar(ComentarioProvider provider) async {
    final ok = await provider.enviar(widget.publicacaoId, _comentario.text);
    if (!mounted) return;
    if (ok) {
      _comentario.clear();
      _foco.requestFocus();
    } else if (provider.erro != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(provider.erro!)));
    }
  }

  Future<void> _excluir(
      ComentarioProvider provider, Comentario comentario) async {
    final ok = await provider.excluir(comentario);
    if (!mounted || ok) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(provider.erro ?? 'Não foi possível excluir.')));
  }

  @override
  Widget build(BuildContext context) {
    final uidAtual = FirebaseAuth.instance.currentUser?.uid;
    return ChangeNotifierProvider(
      create: (_) => ComentarioProvider(_service),
      child: Consumer<ComentarioProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Comentários')),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Column(
                    children: [
                      _cabecalhoPublicacao(context),
                      const Divider(height: 1),
                      Expanded(
                        child: StreamBuilder<List<Comentario>>(
                          stream: _service.acompanhar(widget.publicacaoId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Erro ao carregar os comentários: ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final comentarios = snapshot.data ?? const [];
                            if (comentarios.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Nenhum comentário ainda.\nSeja a primeira pessoa a comentar!',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: comentarios.length,
                              itemBuilder: (context, index) {
                                final comentario = comentarios[index];
                                final meu = comentario.autorId == uidAtual;
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      comentario.autorNome.isEmpty
                                          ? '?'
                                          : comentario.autorNome[0]
                                              .toUpperCase(),
                                    ),
                                  ),
                                  title: Text(comentario.autorNome),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(comentario.texto),
                                      const SizedBox(height: 2),
                                      Text(
                                        formatarData(comentario.data),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  Colors.grey.shade600,
                                            ),
                                      ),
                                    ],
                                  ),
                                  trailing: meu
                                      ? IconButton(
                                          icon: const Icon(
                                              Icons.delete_outline),
                                          tooltip: 'Excluir meu comentário',
                                          onPressed: provider.excluindo
                                              ? null
                                              : () =>
                                                  _excluir(provider, comentario),
                                        )
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      _campoEnvio(context, provider),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cabecalhoPublicacao(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person, size: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.autorNome,
                  style:
                      Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                ),
              ),
              if (widget.data != null)
                Text(
                  formatarData(widget.data),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.texto, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _campoEnvio(BuildContext context, ComentarioProvider provider) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _comentario,
                focusNode: _foco,
                minLines: 1,
                maxLines: 4,
                maxLength: 280,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _enviar(provider),
                decoration: const InputDecoration(
                  hintText: 'Escreva um comentário...',
                  border: OutlineInputBorder(),
                  isDense: true,
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: provider.enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              tooltip: 'Enviar comentário',
              onPressed: provider.enviando ? null : () => _enviar(provider),
            ),
          ],
        ),
      ),
    );
  }
}
