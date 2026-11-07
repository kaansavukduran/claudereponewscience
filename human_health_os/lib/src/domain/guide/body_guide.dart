/// A plain guide to the body's systems and the medical specialties that care
/// for them (U002). Written for Human OS in its own words; the grouping
/// follows the chapter structure of WHO ICD-11 (MMS, 2025) and the specialty
/// names follow the UEMS sections and boards list and Türkiye's
/// specialty-training branches (TUS). No text is copied from an atlas.
///
/// The guide explains where things are and who looks after them. It never
/// names a disease from a value, never says a value is good or bad, and
/// never replaces a clinician.
library;

/// A text in both app languages.
typedef Bilingual = (String en, String tr);

class BodySystem {
  const BodySystem({
    required this.id,
    required this.name,
    required this.what,
    required this.parts,
    required this.specialties,
    this.measurements = const [],
  });

  /// Stable id (`heart`, `lungs`…).
  final String id;
  final Bilingual name;

  /// One or two sentences on what the system does.
  final Bilingual what;

  /// Main parts, short names.
  final List<Bilingual> parts;

  /// Ids in [specialties].
  final List<String> specialties;

  /// Record kind codes in Human OS that measure something of this system.
  final List<String> measurements;
}

class Specialty {
  const Specialty({required this.id, required this.name, required this.what});

  final String id;
  final Bilingual name;
  final Bilingual what;
}

const List<Specialty> specialties = [
  Specialty(
    id: 'family',
    name: ('Family medicine', 'Aile hekimliği'),
    what: (
      'The usual first stop for any health question; coordinates referrals.',
      'Her sağlık sorusu için olağan ilk adres; gerekirse başka bölüme yönlendirir.',
    ),
  ),
  Specialty(
    id: 'internal',
    name: ('Internal medicine', 'İç hastalıkları'),
    what: (
      'Adult medicine across the organs, without surgery.',
      'Yetişkinlerde organların ameliyatsız tıbbı.',
    ),
  ),
  Specialty(
    id: 'cardiology',
    name: ('Cardiology', 'Kardiyoloji'),
    what: ('The heart and blood vessels.', 'Kalp ve damarlar.'),
  ),
  Specialty(
    id: 'cardiac_surgery',
    name: ('Cardiovascular surgery', 'Kalp ve damar cerrahisi'),
    what: (
      'Operations on the heart and blood vessels.',
      'Kalp ve damar ameliyatları.',
    ),
  ),
  Specialty(
    id: 'pulmonology',
    name: ('Pulmonology', 'Göğüs hastalıkları'),
    what: ('The lungs and airways.', 'Akciğerler ve hava yolları.'),
  ),
  Specialty(
    id: 'thoracic_surgery',
    name: ('Thoracic surgery', 'Göğüs cerrahisi'),
    what: (
      'Operations on the chest, lungs and airways.',
      'Göğüs, akciğer ve hava yolu ameliyatları.',
    ),
  ),
  Specialty(
    id: 'neurology',
    name: ('Neurology', 'Nöroloji'),
    what: (
      'The brain, spinal cord and nerves, without surgery.',
      'Beyin, omurilik ve sinirlerin ameliyatsız tıbbı.',
    ),
  ),
  Specialty(
    id: 'neurosurgery',
    name: ('Neurosurgery', 'Beyin ve sinir cerrahisi'),
    what: (
      'Operations on the brain, spine and nerves.',
      'Beyin, omurga ve sinir ameliyatları.',
    ),
  ),
  Specialty(
    id: 'psychiatry',
    name: ('Psychiatry', 'Psikiyatri'),
    what: (
      'Mental health: mood, thinking, behaviour, sleep and addiction.',
      'Ruh sağlığı: duygu durumu, düşünce, davranış, uyku ve bağımlılık.',
    ),
  ),
  Specialty(
    id: 'gastroenterology',
    name: ('Gastroenterology', 'Gastroenteroloji'),
    what: (
      'The digestive tract, liver and pancreas.',
      'Sindirim kanalı, karaciğer ve pankreas.',
    ),
  ),
  Specialty(
    id: 'general_surgery',
    name: ('General surgery', 'Genel cerrahi'),
    what: (
      'Operations mainly on the abdomen, digestive organs, breast and thyroid.',
      'Başta karın, sindirim organları, meme ve tiroit ameliyatları.',
    ),
  ),
  Specialty(
    id: 'nephrology',
    name: ('Nephrology', 'Nefroloji'),
    what: (
      'The kidneys, fluids and salts of the body.',
      'Böbrekler, vücudun sıvı ve tuz dengesi.',
    ),
  ),
  Specialty(
    id: 'urology',
    name: ('Urology', 'Üroloji'),
    what: (
      'The urinary tract and the male reproductive organs.',
      'İdrar yolları ve erkek üreme organları.',
    ),
  ),
  Specialty(
    id: 'endocrinology',
    name: ('Endocrinology', 'Endokrinoloji'),
    what: (
      'Hormones and the glands that make them; metabolism.',
      'Hormonlar, onları yapan bezler ve metabolizma.',
    ),
  ),
  Specialty(
    id: 'haematology',
    name: ('Haematology', 'Hematoloji'),
    what: (
      'Blood, bone marrow and clotting.',
      'Kan, kemik iliği ve pıhtılaşma.',
    ),
  ),
  Specialty(
    id: 'immunology',
    name: ('Immunology and allergy', 'İmmünoloji ve alerji'),
    what: (
      'The immune system and allergies.',
      'Bağışıklık sistemi ve alerjiler.',
    ),
  ),
  Specialty(
    id: 'infectious',
    name: (
      'Infectious diseases',
      'Enfeksiyon hastalıkları ve klinik mikrobiyoloji',
    ),
    what: ('Infections and their prevention.', 'Enfeksiyonlar ve önlenmeleri.'),
  ),
  Specialty(
    id: 'rheumatology',
    name: ('Rheumatology', 'Romatoloji'),
    what: (
      'Joints, muscles and connective tissue, without surgery.',
      'Eklem, kas ve bağ dokusunun ameliyatsız tıbbı.',
    ),
  ),
  Specialty(
    id: 'orthopaedics',
    name: ('Orthopaedics and traumatology', 'Ortopedi ve travmatoloji'),
    what: (
      'Bones, joints and injuries, including operations.',
      'Kemikler, eklemler ve yaralanmalar; ameliyatlar dahil.',
    ),
  ),
  Specialty(
    id: 'rehab',
    name: (
      'Physical medicine and rehabilitation',
      'Fiziksel tıp ve rehabilitasyon',
    ),
    what: (
      'Movement, function and recovery.',
      'Hareket, işlev ve iyileşme süreci.',
    ),
  ),
  Specialty(
    id: 'dermatology',
    name: ('Dermatology', 'Deri ve zührevi hastalıkları (dermatoloji)'),
    what: ('The skin, hair and nails.', 'Deri, saç ve tırnaklar.'),
  ),
  Specialty(
    id: 'ophthalmology',
    name: ('Ophthalmology', 'Göz hastalıkları'),
    what: ('The eyes and sight.', 'Gözler ve görme.'),
  ),
  Specialty(
    id: 'ent',
    name: ('Ear, nose and throat (ENT)', 'Kulak burun boğaz (KBB)'),
    what: (
      'Ears and hearing, nose, sinuses, throat and voice.',
      'Kulak ve işitme, burun, sinüsler, boğaz ve ses.',
    ),
  ),
  Specialty(
    id: 'gynaecology',
    name: ('Obstetrics and gynaecology', 'Kadın hastalıkları ve doğum'),
    what: (
      'The female reproductive organs, pregnancy and birth.',
      'Kadın üreme organları, gebelik ve doğum.',
    ),
  ),
  Specialty(
    id: 'paediatrics',
    name: ('Paediatrics', 'Çocuk sağlığı ve hastalıkları'),
    what: (
      'Children and adolescents, across the organs.',
      'Çocuklar ve ergenler, tüm organlarıyla.',
    ),
  ),
  Specialty(
    id: 'oncology',
    name: ('Medical oncology', 'Tıbbi onkoloji'),
    what: (
      'Medicine for cancer, alongside surgery and radiotherapy.',
      'Kanserin ilaç tedavisi; cerrahi ve ışın tedavisiyle birlikte.',
    ),
  ),
  Specialty(
    id: 'dentistry',
    name: ('Dentistry', 'Diş hekimliği'),
    what: ('Teeth, gums and the mouth.', 'Dişler, diş etleri ve ağız.'),
  ),
  Specialty(
    id: 'emergency',
    name: ('Emergency medicine', 'Acil tıp'),
    what: (
      'Sudden or severe illness and injury, at any hour.',
      'Ani ya da ağır hastalık ve yaralanmalar, günün her saati.',
    ),
  ),
];

const List<BodySystem> bodySystems = [
  BodySystem(
    id: 'heart',
    name: ('Heart and blood vessels', 'Kalp ve damarlar'),
    what: (
      'The heart pumps blood through arteries and veins, carrying oxygen and nutrients to every tissue.',
      'Kalp, kanı atardamar ve toplardamarlar yoluyla pompalar; oksijeni ve besinleri her dokuya taşır.',
    ),
    parts: [
      ('Heart', 'Kalp'),
      ('Arteries', 'Atardamarlar'),
      ('Veins', 'Toplardamarlar'),
      ('Capillaries', 'Kılcal damarlar'),
    ],
    specialties: ['cardiology', 'cardiac_surgery', 'internal'],
    measurements: ['vital.blood_pressure', 'vital.resting_heart_rate'],
  ),
  BodySystem(
    id: 'lungs',
    name: ('Lungs and airways', 'Akciğerler ve hava yolları'),
    what: (
      'Air travels through the nose, throat and windpipe into the lungs, where oxygen enters the blood and carbon dioxide leaves it.',
      'Hava burun, boğaz ve soluk borusundan akciğerlere ulaşır; orada oksijen kana geçer, karbondioksit kandan ayrılır.',
    ),
    parts: [
      ('Windpipe (trachea)', 'Soluk borusu (trakea)'),
      ('Bronchi', 'Bronşlar'),
      ('Lungs', 'Akciğerler'),
      ('Diaphragm', 'Diyafram'),
    ],
    specialties: ['pulmonology', 'thoracic_surgery', 'ent'],
    measurements: ['vital.oxygen_saturation', 'vital.respiratory_rate'],
  ),
  BodySystem(
    id: 'brain',
    name: ('Brain and nerves', 'Beyin ve sinirler'),
    what: (
      'The brain and spinal cord process information and send signals through the nerves to move, feel and control the organs.',
      'Beyin ve omurilik bilgiyi işler; sinirler yoluyla hareket, duyu ve organların denetimi için sinyal gönderir.',
    ),
    parts: [
      ('Brain', 'Beyin'),
      ('Spinal cord', 'Omurilik'),
      ('Nerves', 'Sinirler'),
    ],
    specialties: ['neurology', 'neurosurgery'],
  ),
  BodySystem(
    id: 'mind',
    name: ('Mind and sleep', 'Ruh sağlığı ve uyku'),
    what: (
      'Mood, thinking, behaviour and sleep, which affect and are affected by the rest of the body.',
      'Duygu durumu, düşünce, davranış ve uyku; vücudun geri kalanını etkiler ve ondan etkilenir.',
    ),
    parts: [
      ('Mood', 'Duygu durumu'),
      ('Thinking and memory', 'Düşünce ve bellek'),
      ('Sleep', 'Uyku'),
    ],
    specialties: ['psychiatry', 'neurology', 'family'],
  ),
  BodySystem(
    id: 'digestion',
    name: ('Digestion', 'Sindirim'),
    what: (
      'The mouth, stomach and intestines break food down and absorb it; the liver and pancreas help with digestion and metabolism.',
      'Ağız, mide ve bağırsaklar besinleri parçalar ve emer; karaciğer ve pankreas sindirime ve metabolizmaya yardım eder.',
    ),
    parts: [
      ('Oesophagus', 'Yemek borusu'),
      ('Stomach', 'Mide'),
      ('Intestines', 'Bağırsaklar'),
      ('Liver', 'Karaciğer'),
      ('Pancreas', 'Pankreas'),
    ],
    specialties: ['gastroenterology', 'general_surgery', 'internal'],
  ),
  BodySystem(
    id: 'kidneys',
    name: ('Kidneys and urinary tract', 'Böbrekler ve idrar yolları'),
    what: (
      'The kidneys filter the blood, balance water and salts, and make urine, which leaves through the bladder.',
      'Böbrekler kanı süzer, su ve tuz dengesini korur ve idrar yapar; idrar mesaneden atılır.',
    ),
    parts: [
      ('Kidneys', 'Böbrekler'),
      ('Ureters', 'Üreterler'),
      ('Bladder', 'Mesane'),
    ],
    specialties: ['nephrology', 'urology'],
    measurements: ['vital.blood_pressure'],
  ),
  BodySystem(
    id: 'hormones',
    name: ('Hormones and metabolism', 'Hormonlar ve metabolizma'),
    what: (
      'Glands such as the thyroid, pancreas and adrenals release hormones that steer growth, energy use and many other processes.',
      'Tiroit, pankreas ve böbreküstü bezleri gibi bezler büyümeyi, enerji kullanımını ve birçok süreci yöneten hormonlar salgılar.',
    ),
    parts: [
      ('Thyroid', 'Tiroit'),
      ('Pituitary', 'Hipofiz'),
      ('Adrenal glands', 'Böbreküstü bezleri'),
      ('Pancreas (insulin)', 'Pankreas (insülin)'),
    ],
    specialties: ['endocrinology', 'internal'],
  ),
  BodySystem(
    id: 'blood',
    name: ('Blood and immunity', 'Kan ve bağışıklık'),
    what: (
      'Blood cells carry oxygen, fight infection and stop bleeding; the immune system defends the body.',
      'Kan hücreleri oksijen taşır, enfeksiyonla savaşır ve kanamayı durdurur; bağışıklık sistemi vücudu korur.',
    ),
    parts: [
      ('Red blood cells', 'Alyuvarlar'),
      ('White blood cells', 'Akyuvarlar'),
      ('Platelets', 'Trombositler'),
      ('Lymph nodes', 'Lenf düğümleri'),
    ],
    specialties: ['haematology', 'immunology', 'infectious'],
  ),
  BodySystem(
    id: 'movement',
    name: ('Bones, joints and muscles', 'Kemikler, eklemler ve kaslar'),
    what: (
      'The skeleton gives shape and protection; joints and muscles make movement possible.',
      'İskelet şekil verir ve korur; eklemler ve kaslar hareketi mümkün kılar.',
    ),
    parts: [
      ('Bones', 'Kemikler'),
      ('Joints', 'Eklemler'),
      ('Muscles', 'Kaslar'),
      ('Spine', 'Omurga'),
    ],
    specialties: ['orthopaedics', 'rheumatology', 'rehab'],
    measurements: ['body.height'],
  ),
  BodySystem(
    id: 'skin',
    name: ('Skin, hair and nails', 'Deri, saç ve tırnaklar'),
    what: (
      'The skin protects the body, helps keep its temperature and senses touch.',
      'Deri vücudu korur, sıcaklığını korumaya yardım eder ve dokunmayı algılar.',
    ),
    parts: [('Skin', 'Deri'), ('Hair', 'Saç'), ('Nails', 'Tırnaklar')],
    specialties: ['dermatology'],
  ),
  BodySystem(
    id: 'senses',
    name: ('Eyes, ears, nose and throat', 'Göz, kulak, burun ve boğaz'),
    what: (
      'The organs of sight, hearing, balance, smell and voice.',
      'Görme, işitme, denge, koku ve ses organları.',
    ),
    parts: [
      ('Eyes', 'Gözler'),
      ('Ears', 'Kulaklar'),
      ('Nose and sinuses', 'Burun ve sinüsler'),
      ('Throat and voice', 'Boğaz ve ses'),
    ],
    specialties: ['ophthalmology', 'ent'],
  ),
  BodySystem(
    id: 'reproduction',
    name: ('Reproduction', 'Üreme'),
    what: (
      'The reproductive organs, and pregnancy and birth.',
      'Üreme organları, gebelik ve doğum.',
    ),
    parts: [
      ('Ovaries and uterus', 'Yumurtalıklar ve rahim'),
      ('Testes and prostate', 'Testisler ve prostat'),
      ('Breasts', 'Memeler'),
    ],
    specialties: ['gynaecology', 'urology'],
  ),
  BodySystem(
    id: 'mouth',
    name: ('Mouth and teeth', 'Ağız ve dişler'),
    what: (
      'Teeth and gums for eating and speaking; the start of digestion.',
      'Yemek ve konuşma için dişler ve diş etleri; sindirimin başladığı yer.',
    ),
    parts: [('Teeth', 'Dişler'), ('Gums', 'Diş etleri'), ('Tongue', 'Dil')],
    specialties: ['dentistry'],
  ),
];

Specialty specialtyById(String id) => specialties.firstWhere((s) => s.id == id);

/// Where the structure of this guide comes from (shown on the page).
const List<Bilingual> guideSources = [
  (
    'WHO International Classification of Diseases, 11th revision (ICD-11 MMS): chapter structure by body system. icd.who.int',
    'DSÖ Uluslararası Hastalık Sınıflaması, 11. revizyon (ICD-11 MMS): vücut sistemlerine göre bölüm yapısı. icd.who.int',
  ),
  (
    'European Union of Medical Specialists (UEMS): list of specialist sections and boards. uems.eu',
    'Avrupa Uzman Hekimler Birliği (UEMS): uzmanlık şubeleri ve kurulları listesi. uems.eu',
  ),
  (
    'Türkiye: specialty-training branches named as in medical specialty training (TUS); dentistry as in dental specialty training (DUS).',
    'Türkiye: uzmanlık dalları tıpta uzmanlık eğitimindeki (TUS) adlarıyla; diş hekimliği diş hekimliğinde uzmanlık eğitimindeki (DUS) adıyla.',
  ),
];
