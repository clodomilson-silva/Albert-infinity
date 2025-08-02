import 'package:albert_infinity/services/translation_service.dart';

void main() {
  print('=== Teste do Serviço de Tradução ===');

  // Testar traduções básicas
  print('Teste 1 - Exercícios:');
  print('push-up → ${TranslationService.translate('push-up')}');
  print('squat → ${TranslationService.translate('squat')}');
  print('biceps → ${TranslationService.translate('biceps')}');

  print('\nTeste 2 - Partes do corpo:');
  print('chest → ${TranslationService.translate('chest')}');
  print('back → ${TranslationService.translate('back')}');
  print('shoulders → ${TranslationService.translate('shoulders')}');

  print('\nTeste 3 - Descrições:');
  String description =
      'Stand with feet shoulder-width apart. Lower your body by bending your knees. Keep your chest up and push through your heels to return to starting position.';
  print('Original: $description');
  print('Traduzida: ${TranslationService.translateDescription(description)}');

  print('\nTeste 4 - Termos técnicos:');
  print('strength → ${TranslationService.translate('strength')}');
  print('cardio → ${TranslationService.translate('cardio')}');
  print('endurance → ${TranslationService.translate('endurance')}');

  print('\nTeste 5 - Equipamentos:');
  print('dumbbells → ${TranslationService.translate('dumbbells')}');
  print('barbells → ${TranslationService.translate('barbells')}');
  print(
    'resistance bands → ${TranslationService.translate('resistance bands')}',
  );
}
