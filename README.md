# Mural da Turma — Comentários em tempo real

Aplicativo Flutter conectado ao Firebase para criar publicações e discutir cada
publicação em tempo real.

## Funcionalidades

- Cadastro, login e perfil de usuários com Firebase Authentication.
- Publicações compartilhadas pelo Cloud Firestore.
- Botão de comentários em cada publicação, no mural e no perfil.
- Tela de discussão com a publicação selecionada e apenas os seus comentários.
- Novos comentários e exclusões aparecem automaticamente para todas as contas
  que estiverem na mesma discussão.
- Um usuário só vê o botão para excluir os seus próprios comentários; essa
  restrição também é aplicada por `firestore.rules`.

## Estrutura dos dados

Os comentários ficam na coleção `comentarios`. Cada documento contém:

```text
texto, autorNome, autorId, publicacaoId, data
```

`publicacaoId` recebe o ID do documento da publicação. A consulta filtra por
esse campo, portanto um comentário não aparece em outra discussão.

## Como executar

1. Configure o Firebase para o projeto (caso ainda não esteja configurado):

   ```bash
   dart pub global activate flutterfire_cli
   npm install -g firebase-tools
   firebase login
   dart pub global run flutterfire_cli:flutterfire configure
   ```

2. Publique as regras presentes em `firestore.rules` no console do Firestore
   ou execute `firebase deploy --only firestore:rules`.
3. Execute `flutter pub get` e depois `flutter run`.

## Respostas às questões

1. O Firebase Authentication entrega um UID único para a conta logada. O app o
   salva em `autorId`; as regras conferem esse valor com `request.auth.uid`.
2. O ID do documento da publicação é salvo em `publicacaoId` no comentário e
   usado no filtro da consulta ao Firestore.
3. `StreamBuilder` escuta o `snapshots()` do Firestore e reconstrói a lista a
   cada alteração recebida, sem botão de atualizar.
4. Como todas as contas escutam a mesma consulta em tempo real e o Firestore
   envia suas alterações aos clientes conectados, um comentário criado por uma
   conta atualiza as demais automaticamente.
