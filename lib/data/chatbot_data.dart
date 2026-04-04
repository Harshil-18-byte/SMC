/// Chatbot Knowledge Base
/// Contains structured Q&A data for the SMC Inspection Assistant.
class ChatbotKnowledgeBase {
  /// Map of keywords/phrases to specific medical responses.
  /// The key is a list of triggers (lowercase), and the value is the response key.
  static final Map<List<String>, String> medicalResponses = {
    // --- EMERGENCIES ---
    [
      'heart attack',
      'chest pain',
      'cardiac arrest',
      'heart failure',
      'dil ka daura',
      'hridaya vikaar',
      'छाती में दर्द',
      'हृदय विकार',
      'ह्रदयविकाराचा झटका'
    ]: 'heart_attack',
    [
      'stroke',
      'face drooping',
      'slurred speech',
      'arm weakness',
      'lakwa',
      'lakva',
      'लकवा'
    ]: 'stroke',
    [
      'suicide',
      'kill myself',
      'end my life',
      'depressed',
      'hopeless',
      'atmahatya',
      'आत्महत्या'
    ]: 'suicide',
    [
      'accident',
      'bleeding',
      'injury',
      'trauma',
      'crash',
      'durghatna',
      'apaghaat',
      'दुर्घटना',
      'अपघात'
    ]: 'accident',
    [
      'choking',
      'cannot breathe',
      'blocked airway',
      'dum ghutna',
      'दम घुटना',
      'श्वास कोंडणे'
    ]: 'choking',
    ['burn', 'scald', 'fire', 'jalna', 'bhajne', 'जलना', 'भाजणे']: 'burn',
    ['poison', 'swallowed chemical', 'zeher', 'vishbadha', 'जहर', 'विषबाधा']:
        'poison',

    // --- COMMON AILMENTS ---
    [
      'headache',
      'migraine',
      'head pain',
      'sir dard',
      'sar dard',
      'doke dukhi',
      'डोकं दुखी',
      'सिर दर्द'
    ]: 'headache',
    [
      'fever',
      'temperature',
      'high temp',
      'hot',
      'bukhaar',
      'buhaar',
      'taap',
      'ताप',
      'बुखार'
    ]: 'fever',
    [
      'cough',
      'coughing',
      'sore throat',
      'khaansi',
      'khansi',
      'khokla',
      'खोकला',
      'खांसी'
    ]: 'cough',
    [
      'cold',
      'runny nose',
      'sneezing',
      'congestion',
      'sardi',
      'thandi',
      'सर्दी',
      'थंडी',
      'जुकाम'
    ]: 'cold',
    [
      'stomach',
      'diarrhea',
      'vomiting',
      'nausea',
      'belly pain',
      'gastric',
      'pet dard',
      'pott dukhi',
      'पेट दर्द',
      'पोट दुखी'
    ]: 'stomach',
    ['dehydration', 'thirsty', 'dry mouth', 'paani ki kami', 'पाणी कमी होणे']:
        'dehydration',

    // --- INFECTIOUS DISEASES ---
    ['dengue', 'mosquito', 'dengu', 'डेंगू']: 'dengue',
    ['malaria', 'chills', 'maleriya', 'मलेरिया']: 'malaria',
    ['covid', 'coronavirus', 'sars-cov-2', 'corona', 'कोविड', 'कोरोना']:
        'covid',
    ['tuberculosis', 'tb', 'tibi', 'क्षयरोग']: 'tuberculosis',
    ['chickenpox', 'varicella', 'itchy blister', 'chechak', 'देवी']:
        'chickenpox',
    ['hepatitis', 'jaundice', 'yellow skin', 'yellow eyes', 'piliya', 'काविळ']:
        'hepatitis',
    ['hiv', 'aids']: 'hiv',
    ['typhoid', 'टाइफाइड', 'टायफॉइड']: 'typhoid',

    // --- CHRONIC CONDITIONS ---
    ['diabetes', 'sugar', 'glucose', 'madhumeh', 'मधुमेह']: 'diabetes',
    [
      'blood pressure',
      'hypertension',
      'bp',
      'high bp',
      'raktchaap',
      'raktadaab',
      'रक्तचाप',
      'रक्तदाब'
    ]: 'blood_pressure',
    ['asthma', 'wheezing', 'inhaler', 'dama', 'दमा']: 'asthma',
    ['cancer', 'tumor', 'lump', 'karkaroag', 'कर्करोग']: 'cancer',
    ['thyroid', 'थायराइड']: 'thyroid',

    // --- WOMEN'S HEALTH ---
    [
      'pregnancy',
      'pregnant',
      'maternity',
      'hamal',
      'garbhavastha',
      'गर्भावस्था'
    ]: 'pregnancy',
    ['period', 'menstruation', 'cramps', 'mahina', 'maasik pali', 'मासिक पाळी']:
        'period',
    ['pcos', 'pcod', 'irregular period']: 'pcos',

    // --- CHILD HEALTH ---
    [
      'vaccine',
      'vaccination',
      'immunization',
      'tika',
      'las',
      'टीकाकरण',
      'लसीकरण'
    ]: 'vaccine',
    ['nutrition', 'growth', 'stunted', 'poshan', 'पोषण']: 'child_nutrition',

    // --- MENTAL HEALTH ---
    ['anxiety', 'panic', 'stress', 'worried', 'chinta', 'काळजी']: 'anxiety',
    ['depression', 'sad', 'unhappy', 'mansik tanaav', 'उदासीनता']: 'depression',

    // --- SKIN & HAIR ---
    ['acne', 'pimple', 'skin rash', 'muhasa', 'pimples', 'फोड']: 'acne',
    ['hair loss', 'baldness', 'dandruff', 'baal jhadna', 'केस गळणे']:
        'hair_loss',

    // --- LIFESTYLE ---
    ['diet', 'food', 'weight loss', 'khana', 'aahar', 'आहार']: 'diet',
    ['sleep', 'insomnia', 'tired', 'neend', 'zhop', 'झोप', 'झोप येत नाही']:
        'sleep',
    ['exercise', 'workout', 'fitness', 'vyayam', 'व्यायाम']: 'exercise',

    // --- APPOINTMENTS & SMC ---
    ['appointment', 'booking', 'schedule', 'milne ki vela', 'भेटीची वेळ']:
        'appointment',
    [
      'clinic',
      'site',
      'center',
      'dispensary',
      'haspital',
      'davakhana',
      'दवाखाना',
      'अस्पताल'
    ]: 'bot_site_info',
    ['scheme', 'pmjay', 'inspection card', 'ayushman', 'yojana', 'योजना']:
        'schemes',
  };

  /// Fallback responses when no keyword matches
  static final List<String> defaultFallbackKeys = [
    'fallback_1',
    'fallback_2',
    'fallback_3',
    'fallback_4',
  ];

  /// Find the best response key for a user's input
  static String getResponseKey(String input) {
    final lowerInput = input.toLowerCase().trim();

    // Check strict matches first
    for (final entry in medicalResponses.entries) {
      for (final keyword in entry.key) {
        if (lowerInput.contains(keyword.toLowerCase())) {
          return entry.value;
        }
      }
    }

    // Friendly chit-chat keys
    if (lowerInput.contains('hi') ||
        lowerInput.contains('hello') ||
        lowerInput.contains('hey') ||
        lowerInput.contains('namaste') ||
        lowerInput.contains('namaskar')) {
      return 'chat_hello';
    }
    if (lowerInput.contains('thank') ||
        lowerInput.contains('shukriya') ||
        lowerInput.contains('dhanyavad')) {
      return 'chat_thank_you';
    }
    if (lowerInput.contains('bye') ||
        lowerInput.contains('alvida') ||
        lowerInput.contains('tata')) {
      return 'chat_bye';
    }
    if (lowerInput.contains('who are you') ||
        lowerInput.contains('aap kaun ho')) {
      return 'chat_who_are_you';
    }

    // Default fallback
    return defaultFallbackKeys[
        DateTime.now().second % defaultFallbackKeys.length];
  }
}


