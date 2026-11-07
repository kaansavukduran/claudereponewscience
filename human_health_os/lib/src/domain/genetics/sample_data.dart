/// Invented data for trying the genetics screen without a real genome
/// (ladder G001). Nothing here is real knowledge or a real person: the ids
/// are made up (rs90000xx), the genes and traits are placeholders, and the
/// pack says so in its header and in every row.
library;

/// A small file in the 23andMe layout, invented.
const String sampleGenomeText =
    '''# This is an INVENTED sample file made by Human OS for trying the screen.
# It is not a real person's data.
# We are using reference human assembly build 37.
# rsid\tchromosome\tposition\tgenotype
rs9000001\t1\t100001\tAG
rs9000002\t1\t200002\tCC
rs9000003\t2\t300003\t--
rs9000004\t2\t400004\tAT
rs9000005\t3\t500005\tGG
rs9000006\t7\t600006\tCT
rs9000007\t10\t700007\tDD
rs9000008\t12\t800008\tTT
rs9000009\t19\t900009\tAA
rs9000010\t22\t1000010\tGA
rs9000011\tX\t1100011\tC
rs9000012\tMT\t1200012\tA
''';

/// A pack of invented statements that matches [sampleGenomeText].
const String samplePackText = '''#name: Human OS demonstration pack (INVENTED)
#licence: Invented by the Human OS project for demonstration; public domain (CC0)
#build: 37
#strand: plus
#synthetic: yes
rsid\tgene\tallele\tstatement\tsource\tsource_id\tsource_date\tevidence
rs9000001\tGENE-A\tG\tINVENTED: said to be associated with the example trait one.\tHuman OS demo (invented)\tDEMO-1\t2026-11-07\tnot applicable (invented)
rs9000002\tGENE-B\tT\tINVENTED: said to be associated with the example trait two.\tHuman OS demo (invented)\tDEMO-2\t2026-11-07\tnot applicable (invented)
rs9000003\tGENE-C\tA\tINVENTED: said to be associated with the example trait three.\tHuman OS demo (invented)\tDEMO-3\t2026-11-07\tnot applicable (invented)
rs9000004\tGENE-D\tT\tINVENTED: said to be associated with the example trait four.\tHuman OS demo (invented)\tDEMO-4\t2026-11-07\tnot applicable (invented)
rs9000006\tGENE-E\tC\tINVENTED: said to be associated with the example trait five.\tHuman OS demo (invented)\tDEMO-5\t2026-11-07\tnot applicable (invented)
rs9000099\tGENE-F\tA\tINVENTED: an entry for a variant that the sample file does not contain.\tHuman OS demo (invented)\tDEMO-6\t2026-11-07\tnot applicable (invented)
''';
