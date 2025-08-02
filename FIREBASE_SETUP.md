# 🔥 Configuração do Firebase - Albert Infinity

## Pré-requisitos

1. **Conta no Firebase**: Acesse [Firebase Console](https://console.firebase.google.com)
2. **Node.js**: Instalar versão 16 ou superior
3. **Firebase CLI**: `npm install -g firebase-tools`

## 📋 Passos para Configuração

### 1. Criar Projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com)
2. Clique em "Criar projeto"
3. Nome: `albert-infinity` (ou nome de sua escolha)
4. Habilite Google Analytics (opcional)
5. Clique em "Criar projeto"

### 2. Configurar Authentication

1. No Console Firebase, vá para **Authentication**
2. Clique em "Começar"
3. Vá para a aba **Sign-in method**
4. Habilite **Email/senha**
5. Salve as configurações

### 3. Configurar Firestore Database

1. No Console Firebase, vá para **Firestore Database**
2. Clique em "Criar banco de dados"
3. Escolha **Modo de teste** (por enquanto)
4. Selecione uma localização (ex: southamerica-east1)
5. Clique em "Concluído"

### 4. Configurar o Flutter com Firebase

1. **Instalar Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login no Firebase**:
   ```bash
   firebase login
   ```

3. **Instalar FlutterFire CLI**:
   ```bash
   dart pub global activate flutterfire_cli
   ```

4. **Configurar o projeto Flutter**:
   ```bash
   cd albert_infinity
   flutterfire configure
   ```
   - Selecione o projeto Firebase criado
   - Selecione as plataformas: Web, Android, iOS, Windows
   - Confirme as configurações

5. **Substituir arquivo firebase_options.dart**:
   - O comando acima irá gerar um novo `lib/firebase_options.dart`
   - Substitua o arquivo existente pelo gerado

### 5. Regras de Segurança do Firestore

Substitua as regras do Firestore por:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Regras para usuários autenticados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Regras para dados de treinos (somente leitura para usuários logados)
    match /workouts/{document=**} {
      allow read: if request.auth != null;
    }
  }
}
```

### 6. Testar a Configuração

1. **Execute o app**:
   ```bash
   flutter run -d chrome
   ```

2. **Teste o cadastro**:
   - Abra o app
   - Clique em "Cadastre-se"
   - Preencha os dados
   - Verifique se o usuário foi criado no Firebase Console

3. **Teste o login**:
   - Faça login com as credenciais criadas
   - Verifique se redirecionou para a tela Home

## 🛠️ Estrutura de Dados no Firestore

### Coleção: `users`
```json
{
  "userId": {
    "name": "Nome do Usuário",
    "email": "email@exemplo.com",
    "createdAt": "timestamp",
    "lastLogin": "timestamp"
  }
}
```

### Coleção: `workouts` (futura)
```json
{
  "workoutId": {
    "title": "Nome do Treino",
    "description": "Descrição",
    "duration": 30,
    "difficulty": "iniciante",
    "isPremium": false,
    "exercises": []
  }
}
```

## 🚀 Comandos Úteis

```bash
# Instalar dependências
flutter pub get

# Executar no Chrome
flutter run -d chrome

# Build para produção
flutter build web

# Ver logs do Firebase
firebase functions:log

# Deploy das regras do Firestore
firebase deploy --only firestore:rules
```

## 🔧 Troubleshooting

### Erro: "Firebase project not found"
- Verifique se fez login no Firebase CLI
- Execute `flutterfire configure` novamente

### Erro: "No Firebase options"
- Certifique-se que o arquivo `firebase_options.dart` foi gerado
- Verifique se as opções estão preenchidas corretamente

### Erro: "Network error"
- Verifique sua conexão com a internet
- Certifique-se que o projeto Firebase está ativo

## 📱 Próximos Passos

1. Implementar perfil do usuário
2. Adicionar recuperação de senha
3. Implementar dados de treinos no Firestore
4. Adicionar autenticação com Google
5. Implementar sistema de assinatura premium

## 📞 Suporte

Se encontrar problemas:
1. Verifique a documentação oficial do [FlutterFire](https://firebase.flutter.dev/)
2. Consulte o [Firebase Console](https://console.firebase.google.com) para verificar configurações
3. Execute `flutter doctor` para verificar problemas do Flutter
