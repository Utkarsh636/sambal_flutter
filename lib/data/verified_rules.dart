class VerifiedFact {
  final String value;
  final String sourceUrl;
  final String sourceTitle;
  final String lastChecked;
  final String applicability;

  const VerifiedFact({
    required this.value,
    required this.sourceUrl,
    required this.sourceTitle,
    required this.lastChecked,
    required this.applicability,
  });
}

class StateRules {
  final String state;
  final String portalName;
  final String portalUrl;
  final VerifiedFact freeRegistrationDays;
  final VerifiedFact delayedAuthority;
  final VerifiedFact? freeFee;
  final VerifiedFact? delayedFee;
  final VerifiedFact registrationOffice;
  final List<VerifiedFact> requiredDocuments;
  final String lastVerified;
  final bool districtDataImported;

  const StateRules({
    required this.state,
    required this.portalName,
    required this.portalUrl,
    required this.freeRegistrationDays,
    required this.delayedAuthority,
    this.freeFee,
    this.delayedFee,
    required this.registrationOffice,
    required this.requiredDocuments,
    required this.lastVerified,
    this.districtDataImported = false,
  });
}

class NationalRules {
  static const freeRegistrationDays = VerifiedFact(
    value: '21 दिन / 21 days',
    sourceUrl:
        'https://services.india.gov.in/service/detail/civil-registration-system-birth-and-death-certificate',
    sourceTitle: 'RBD Act 1969, §13(1)',
    lastChecked: '2026-10-29',
    applicability: 'All India',
  );

  static const delayedRegistration = VerifiedFact(
    value:
        '21 दिन के बाद: निर्धारित प्राधिकारी की अनुमति, शुल्क और शपथ पत्र। 1 वर्ष बाद: मजिस्ट्रेट का आदेश।',
    sourceUrl:
        'https://services.india.gov.in/service/detail/civil-registration-system-birth-and-death-certificate',
    sourceTitle: 'RBD Act 1969, §13(2)–(3)',
    lastChecked: '2026-10-29',
    applicability: 'All India — state fees and authority vary',
  );

  static const requiredDocuments = [
    'मृत्यु प्रमाण पत्र फॉर्म (Form No. 2) / Death certificate form',
    'मृतक का पहचान पत्र / Identity proof of deceased',
    'आवेदक का पहचान पत्र / Identity proof of applicant',
    'अस्पताल का मृत्यु प्रमाण (यदि अस्पताल में मृत्यु) / Hospital death certificate (if hospital death)',
    'पंचनामा / पुलिस रिपोर्ट (दुर्घटना/अप्राकृतिक मृत्यु में) / Panchnama / Police report (if accident/unnatural)',
    'शपथ पत्र (विलंबित पंजीकरण में) / Affidavit (for delayed registration)',
  ];
}

class VerifiedStateData {
  static const List<String> coveredStates = [
    'Uttar Pradesh',
    'Bihar',
    'Maharashtra',
  ];

  static final Map<String, StateRules> rules = {
    'Uttar Pradesh': const StateRules(
      state: 'Uttar Pradesh',
      portalName: 'UP e-District',
      portalUrl:
          'https://services.india.gov.in/service/detail/uttar-pradesh-e-district-services',
      freeRegistrationDays: VerifiedFact(
        value: '21 दिन — निःशुल्क / 21 days — free',
        sourceUrl:
            'https://services.india.gov.in/service/detail/uttar-pradesh-e-district-services',
        sourceTitle: 'UP e-District — Death Registration',
        lastChecked: '2026-10-29',
        applicability: 'Uttar Pradesh — all districts',
      ),
      delayedAuthority: VerifiedFact(
        value:
            '21–30 दिन: रजिस्ट्रार। 30 दिन–1 वर्ष: ADM/SDM। 1 वर्ष बाद: प्रथम श्रेणी मजिस्ट्रेट।',
        sourceUrl:
            'https://services.india.gov.in/service/detail/uttar-pradesh-e-district-services',
        sourceTitle: 'UP e-District — Death Registration',
        lastChecked: '2026-10-29',
        applicability: 'Uttar Pradesh',
      ),
      registrationOffice: VerifiedFact(
        value:
            'नगर निगम / नगर पालिका / ग्राम पंचायत — जहाँ मृत्यु हुई',
        sourceUrl:
            'https://services.india.gov.in/service/detail/uttar-pradesh-e-district-services',
        sourceTitle: 'UP e-District',
        lastChecked: '2026-10-29',
        applicability: 'Uttar Pradesh — varies by urban/rural',
      ),
      requiredDocuments: [
        VerifiedFact(
          value: 'फॉर्म संख्या 2 (मृत्यु सूचना) / Form No. 2',
          sourceUrl:
              'https://services.india.gov.in/service/detail/uttar-pradesh-e-district-services',
          sourceTitle: 'UP e-District',
          lastChecked: '2026-10-29',
          applicability: 'UP',
        ),
        VerifiedFact(
          value: 'अस्पताल प्रमाण या गाँव प्रधान / चौकीदार की रिपोर्ट',
          sourceUrl:
              'https://services.india.gov.in/service/detail/uttar-pradesh-e-district-services',
          sourceTitle: 'UP e-District',
          lastChecked: '2026-10-29',
          applicability: 'UP',
        ),
        VerifiedFact(
          value: 'आवेदक का आधार कार्ड / पहचान पत्र',
          sourceUrl:
              'https://services.india.gov.in/service/detail/uttar-pradesh-e-district-services',
          sourceTitle: 'UP e-District',
          lastChecked: '2026-10-29',
          applicability: 'UP',
        ),
      ],
      lastVerified: '2026-10-29',
    ),
    'Bihar': const StateRules(
      state: 'Bihar',
      portalName: 'Bihar RTPS / ServicePlus',
      portalUrl: 'https://serviceonline.bihar.gov.in/',
      freeRegistrationDays: VerifiedFact(
        value: '21 दिन — निःशुल्क / 21 days — free',
        sourceUrl: 'https://serviceonline.bihar.gov.in/',
        sourceTitle: 'Bihar RTPS — Death Registration',
        lastChecked: '2026-10-29',
        applicability: 'Bihar — all districts',
      ),
      delayedAuthority: VerifiedFact(
        value:
            '21 दिन बाद: प्रखंड विकास अधिकारी (BDO) / अंचलाधिकारी। 1 वर्ष बाद: मजिस्ट्रेट।',
        sourceUrl: 'https://serviceonline.bihar.gov.in/',
        sourceTitle: 'Bihar RTPS',
        lastChecked: '2026-10-29',
        applicability: 'Bihar',
      ),
      registrationOffice: VerifiedFact(
        value:
            'नगर निगम / नगर परिषद / प्रखंड कार्यालय — जहाँ मृत्यु हुई',
        sourceUrl: 'https://serviceonline.bihar.gov.in/',
        sourceTitle: 'Bihar RTPS',
        lastChecked: '2026-10-29',
        applicability: 'Bihar — varies by urban/rural',
      ),
      requiredDocuments: [
        VerifiedFact(
          value: 'मृत्यु सूचना फॉर्म / Death intimation form',
          sourceUrl: 'https://serviceonline.bihar.gov.in/',
          sourceTitle: 'Bihar RTPS',
          lastChecked: '2026-10-29',
          applicability: 'Bihar',
        ),
        VerifiedFact(
          value: 'अस्पताल प्रमाण या मुखिया / वार्ड पार्षद की रिपोर्ट',
          sourceUrl: 'https://serviceonline.bihar.gov.in/',
          sourceTitle: 'Bihar RTPS',
          lastChecked: '2026-10-29',
          applicability: 'Bihar',
        ),
        VerifiedFact(
          value: 'आवेदक का पहचान पत्र (आधार / वोटर ID)',
          sourceUrl: 'https://serviceonline.bihar.gov.in/',
          sourceTitle: 'Bihar RTPS',
          lastChecked: '2026-10-29',
          applicability: 'Bihar',
        ),
      ],
      lastVerified: '2026-10-29',
    ),
    'Maharashtra': const StateRules(
      state: 'Maharashtra',
      portalName: 'Aaple Sarkar',
      portalUrl: 'https://aaplesarkar.mahaonline.gov.in/',
      freeRegistrationDays: VerifiedFact(
        value: '21 दिन — निःशुल्क / 21 days — free',
        sourceUrl: 'https://aaplesarkar.mahaonline.gov.in/',
        sourceTitle: 'Maharashtra Aaple Sarkar — Death Registration',
        lastChecked: '2026-10-29',
        applicability: 'Maharashtra — all districts',
      ),
      delayedAuthority: VerifiedFact(
        value:
            '21–30 दिन: रजिस्ट्रार, शुल्क सहित। 30 दिन–1 वर्ष: SDM/ADM। 1 वर्ष बाद: प्रथम श्रेणी मजिस्ट्रेट। नगर निगम क्षेत्र में शुल्क भिन्न हो सकता है।',
        sourceUrl: 'https://aaplesarkar.mahaonline.gov.in/',
        sourceTitle: 'Maharashtra Aaple Sarkar',
        lastChecked: '2026-10-29',
        applicability:
            'Maharashtra — municipal corporation by-laws may vary fees',
      ),
      registrationOffice: VerifiedFact(
        value:
            'महानगरपालिका / नगरपालिका / ग्राम पंचायत — जहाँ मृत्यु हुई',
        sourceUrl: 'https://aaplesarkar.mahaonline.gov.in/',
        sourceTitle: 'Aaple Sarkar',
        lastChecked: '2026-10-29',
        applicability:
            'Maharashtra — varies by urban/rural, corporation by-laws apply',
      ),
      requiredDocuments: [
        VerifiedFact(
          value: 'फॉर्म नं. 2 (मृत्यु सूचना) / Form No. 2',
          sourceUrl: 'https://aaplesarkar.mahaonline.gov.in/',
          sourceTitle: 'Aaple Sarkar',
          lastChecked: '2026-10-29',
          applicability: 'Maharashtra',
        ),
        VerifiedFact(
          value: 'अस्पताल का मृत्यु प्रमाण पत्र / Hospital death certificate',
          sourceUrl: 'https://aaplesarkar.mahaonline.gov.in/',
          sourceTitle: 'Aaple Sarkar',
          lastChecked: '2026-10-29',
          applicability: 'Maharashtra',
        ),
        VerifiedFact(
          value: 'आवेदक का आधार कार्ड',
          sourceUrl: 'https://aaplesarkar.mahaonline.gov.in/',
          sourceTitle: 'Aaple Sarkar',
          lastChecked: '2026-10-29',
          applicability: 'Maharashtra',
        ),
      ],
      lastVerified: '2026-10-29',
    ),
  };

  static StateRules? forState(String state) => rules[state];

  static bool isVerified(String state) => rules.containsKey(state);
}
