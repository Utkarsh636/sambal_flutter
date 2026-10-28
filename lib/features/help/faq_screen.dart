import 'package:flutter/material.dart';

import '../case/case_controller.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hindi = SambalScope.of(context).isHindi;
    final colors = Theme.of(context).colorScheme;

    String t(String hi, String en) => hindi ? hi : en;

    final faqs = [
      _Faq(
        qHi: 'मृत्यु प्रमाणपत्र कितने दिन में बनवाना ज़रूरी है?',
        qEn: 'How soon must a death certificate be registered?',
        aHi: 'मृत्यु के 21 दिनों के भीतर पंजीकरण निःशुल्क है। 22-30 दिन में विलंब शुल्क लगता है। 30 दिन से 1 वर्ष तक निर्धारित प्राधिकारी की अनुमति चाहिए। 1 वर्ष बाद मजिस्ट्रेट का आदेश आवश्यक है।\n\n(जन्म और मृत्यु पंजीकरण अधिनियम 1969, धारा 13)',
        aEn: 'Registration within 21 days of death is free. After 22-30 days, a late fee applies. Between 30 days and 1 year, permission from a prescribed authority is needed. After 1 year, a magistrate\'s order is required.\n\n(Registration of Births and Deaths Act 1969, Section 13)',
      ),
      _Faq(
        qHi: 'मृत्यु प्रमाणपत्र बनवाने के लिए कौन-कौन से दस्तावेज़ चाहिए?',
        qEn: 'What documents are needed for a death certificate?',
        aHi: 'सामान्यतः चाहिए:\n• मृत्यु का मेडिकल प्रमाण (फॉर्म 4 या अस्पताल प्रमाणपत्र)\n• सूचनादाता का पहचान पत्र\n• मृतक का पहचान पत्र\n• पता प्रमाण\n\nदुर्घटना/अप्राकृतिक मृत्यु में FIR और पोस्टमार्टम रिपोर्ट भी चाहिए। राज्य और स्थानीय निकाय के अनुसार अतिरिक्त दस्तावेज़ माँगे जा सकते हैं।',
        aEn: 'Generally required:\n• Medical cause-of-death certificate (Form 4 or hospital certificate)\n• Informant\'s identity proof\n• Deceased\'s identity proof\n• Address proof\n\nFor accidental/unnatural death, FIR copy and postmortem report are also needed. Additional documents may vary by state and local body.',
      ),
      _Faq(
        qHi: 'अगर 21 दिन बीत गए तो क्या करें?',
        qEn: 'What if 21 days have passed?',
        aHi: '21 दिन बीतने के बाद भी पंजीकरण संभव है — बस विलंब शुल्क और प्राधिकारी की अनुमति लग सकती है। चिंता न करें, Sambal आपको सही कदम बताएगा।',
        aEn: 'Registration is still possible after 21 days — there may be a late fee and authority permission needed. Don\'t worry, Sambal will guide you through the right steps.',
      ),
      _Faq(
        qHi: 'ऑनलाइन आवेदन कर सकते हैं?',
        qEn: 'Can I apply online?',
        aHi: 'कई राज्यों में ऑनलाइन आवेदन उपलब्ध है:\n• UP: e-District portal\n• Bihar: RTPS ServicePlus\n• MP: eService portal\n• Rajasthan: Pehchan CRS\n• Maharashtra: Aaple Sarkar\n\nSambal आपके राज्य का सही पोर्टल लिंक दिखाता है।',
        aEn: 'Online application is available in many states:\n• UP: e-District portal\n• Bihar: RTPS ServicePlus\n• MP: eService portal\n• Rajasthan: Pehchan CRS\n• Maharashtra: Aaple Sarkar\n\nSambal shows the correct portal link for your state.',
      ),
      _Faq(
        qHi: 'मृत्यु प्रमाणपत्र के बाद और क्या करना होता है?',
        qEn: 'What else needs to be done after getting the certificate?',
        aHi: 'मृत्यु प्रमाणपत्र मिलने के बाद:\n• बैंक खाते में नॉमिनी क्लेम\n• जीवन बीमा दावा\n• EPF/PPF नामांकन\n• पेंशन हस्तांतरण\n• राशन कार्ड अपडेट\n• संपत्ति म्यूटेशन\n\nSambal का "रोडमैप" सेक्शन इन सभी चरणों में मदद करता है।',
        aEn: 'After receiving the death certificate:\n• Bank account nominee claim\n• Life insurance claim\n• EPF/PPF nomination\n• Pension transfer\n• Ration card update\n• Property mutation\n\nSambal\'s "Roadmap" section helps with all these steps.',
      ),
      _Faq(
        qHi: 'क्या Sambal मेरा निजी डेटा कहीं भेजता है?',
        qEn: 'Does Sambal send my personal data anywhere?',
        aHi: 'नहीं। आपके स्कैन किए दस्तावेज़ सिर्फ़ आपके फ़ोन पर रहते हैं। OCR (टेक्स्ट पहचान) भी फ़ोन पर होता है। AI सहायक को कोई नाम, फ़ोन नंबर, आधार, या दस्तावेज़ की तस्वीर नहीं भेजी जाती।',
        aEn: 'No. Your scanned documents stay only on your phone. OCR (text recognition) also runs on-device. No names, phone numbers, Aadhaar, or document images are sent to the AI assistant.',
      ),
      _Faq(
        qHi: 'Sambal में दिखाई गई जानकारी कितनी सही है?',
        qEn: 'How accurate is the information shown in Sambal?',
        aHi: 'Sambal केवल आधिकारिक स्रोतों से सत्यापित जानकारी दिखाता है। जहाँ जिला-स्तरीय जानकारी उपलब्ध नहीं है, वहाँ "सत्यापित नहीं" दिखाया जाता है। अंतिम निर्णय से पहले हमेशा आधिकारिक पोर्टल या स्थानीय कार्यालय से पुष्टि करें।',
        aEn: 'Sambal shows only information verified from official sources. Where district-level data is unavailable, "Not verified yet" is shown. Always confirm on the official portal or local office before making final decisions.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t('अक्सर पूछे जाने वाले प्रश्न', 'FAQ')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t('मृत्यु प्रमाणपत्र और आगे की प्रक्रिया',
                'Death certificate and next steps'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...faqs.asMap().entries.map((entry) {
            final faq = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    '${entry.key + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                title: Text(
                  hindi ? faq.qHi : faq.qEn,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    hindi ? faq.aHi : faq.aEn,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Card(
            color: colors.secondaryContainer.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                t('Sambal एक सहायता ऐप है — वकील, सरकारी प्राधिकारी, या आपातकालीन सेवा नहीं। कानूनी विरासत, संपत्ति बँटवारे, या विवाद से जुड़े प्रश्नों के लिए कृपया वकील या संबंधित प्राधिकारी से संपर्क करें।',
                    'Sambal is a support app — not a lawyer, government authority, or emergency service. For legal inheritance, property share, or dispute questions, please consult a lawyer or the relevant authority.'),
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSecondaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Faq {
  final String qHi;
  final String qEn;
  final String aHi;
  final String aEn;

  const _Faq({
    required this.qHi,
    required this.qEn,
    required this.aHi,
    required this.aEn,
  });
}
