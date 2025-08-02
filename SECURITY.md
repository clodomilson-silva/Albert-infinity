# 🔐 Configuração de Segurança - Albert Infinity

## ⚠️ ARQUIVOS SENSÍVEIS

Os seguintes arquivos contêm credenciais e **NUNCA** devem ser commitados no Git:

### Firebase
- `lib/firebase_options.dart` - Configurações do Firebase
- `android/app/google-services.json` - Configurações Android do Firebase
- `ios/Runner/GoogleService-Info.plist` - Configurações iOS do Firebase

### Android Signing
- `*.keystore` - Chaves de assinatura Android
- `*.jks` - Java KeyStore files
- `key.properties` - Propriedades de chave Android

### Variáveis de Ambiente
- `.env*` - Arquivos de ambiente com API keys

## 🛠️ Como Configurar

### 1. Firebase
1. Vá para [Firebase Console](https://console.firebase.google.com)
2. Selecione seu projeto
3. Vá em **Project Settings** > **General**
4. Baixe:
   - `google-services.json` para Android
   - `GoogleService-Info.plist` para iOS
5. Execute: `dart run flutterfire_cli:flutterfire configure`

### 2. Templates Disponíveis
- `lib/firebase_options.dart.template` - Template para Firebase options
- `android/app/google-services.json.template` - Template para Google Services

### 3. Configuração Local
```bash
# Copie os templates e preencha com suas credenciais
cp lib/firebase_options.dart.template lib/firebase_options.dart
cp android/app/google-services.json.template android/app/google-services.json

# Edite os arquivos com suas credenciais reais
```

## 🚨 Segurança

### Arquivos Protegidos pelo .gitignore:
- ✅ Configurações Firebase
- ✅ Chaves de assinatura Android
- ✅ Certificados iOS
- ✅ Variáveis de ambiente
- ✅ Arquivos de backup
- ✅ Bancos de dados locais

### Se você cometeu credenciais por acidente:
```bash
# Remova do histórico Git
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch android/app/google-services.json' \
--prune-empty --tag-name-filter cat -- --all

# Force push (cuidado!)
git push origin --force --all
```

## 📚 Recursos
- [Firebase Security](https://firebase.google.com/docs/rules)
- [Flutter Security](https://flutter.dev/docs/deployment/security)
- [Git Security](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)
