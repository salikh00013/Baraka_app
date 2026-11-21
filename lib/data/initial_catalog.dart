import '../models/product.dart';

/// Starter product-name catalog. Prices and stock are entered later by BARAKA
/// administrators and must come from Supabase, not from this static list.
const initialCatalog = <CatalogProduct>[
  // Oziq-ovqat
  CatalogProduct(id: 'g001', name: 'Un', category: 'Oziq-ovqat', unit: ProductUnit.kg),
  CatalogProduct(id: 'g002', name: 'Shakar', category: 'Oziq-ovqat', unit: ProductUnit.kg),
  CatalogProduct(id: 'g003', name: 'Guruch', category: 'Oziq-ovqat', unit: ProductUnit.kg),
  CatalogProduct(id: 'g004', name: 'Makaron', category: 'Oziq-ovqat', unit: ProductUnit.pachka),
  CatalogProduct(id: 'g005', name: 'Grechka', category: 'Oziq-ovqat', unit: ProductUnit.kg),
  CatalogProduct(id: 'g006', name: 'Mosh', category: 'Oziq-ovqat', unit: ProductUnit.kg),
  CatalogProduct(id: 'g007', name: 'Loviya', category: 'Oziq-ovqat', unit: ProductUnit.kg),
  CatalogProduct(id: 'g008', name: 'No‘xat', category: 'Oziq-ovqat', unit: ProductUnit.kg),
  CatalogProduct(id: 'g009', name: 'O‘simlik yog‘i', category: 'Oziq-ovqat', unit: ProductUnit.litr),
  CatalogProduct(id: 'g010', name: 'Tuz', category: 'Oziq-ovqat', unit: ProductUnit.pachka),
  CatalogProduct(id: 'g011', name: 'Choy', category: 'Oziq-ovqat', unit: ProductUnit.pachka),
  CatalogProduct(id: 'g012', name: 'Qahva', category: 'Oziq-ovqat', unit: ProductUnit.quti),
  CatalogProduct(id: 'g013', name: 'Tuxum', category: 'Oziq-ovqat', unit: ProductUnit.dona),
  CatalogProduct(id: 'g014', name: 'Non', category: 'Oziq-ovqat', unit: ProductUnit.dona),
  CatalogProduct(id: 'g015', name: 'Suxari', category: 'Oziq-ovqat', unit: ProductUnit.pachka),
  CatalogProduct(id: 'g016', name: 'Pechenye', category: 'Oziq-ovqat', unit: ProductUnit.kg),
  CatalogProduct(id: 'g017', name: 'Konfet', category: 'Oziq-ovqat', unit: ProductUnit.kg),
  CatalogProduct(id: 'g018', name: 'Shokolad', category: 'Oziq-ovqat', unit: ProductUnit.dona),
  CatalogProduct(id: 'g019', name: 'Tomat pastasi', category: 'Oziq-ovqat', unit: ProductUnit.quti),
  CatalogProduct(id: 'g020', name: 'Mayonez', category: 'Oziq-ovqat', unit: ProductUnit.quti),

  // Sabzavotlar
  CatalogProduct(id: 'v001', name: 'Kartoshka', category: 'Sabzavotlar', unit: ProductUnit.kg),
  CatalogProduct(id: 'v002', name: 'Piyoz', category: 'Sabzavotlar', unit: ProductUnit.kg),
  CatalogProduct(id: 'v003', name: 'Sabzi', category: 'Sabzavotlar', unit: ProductUnit.kg),
  CatalogProduct(id: 'v004', name: 'Karam', category: 'Sabzavotlar', unit: ProductUnit.kg),
  CatalogProduct(id: 'v005', name: 'Pomidor', category: 'Sabzavotlar', unit: ProductUnit.kg),
  CatalogProduct(id: 'v006', name: 'Bodring', category: 'Sabzavotlar', unit: ProductUnit.kg),
  CatalogProduct(id: 'v007', name: 'Sarimsoq', category: 'Sabzavotlar', unit: ProductUnit.kg),
  CatalogProduct(id: 'v008', name: 'Bulgor qalampiri', category: 'Sabzavotlar', unit: ProductUnit.kg),
  CatalogProduct(id: 'v009', name: 'Baqlajon', category: 'Sabzavotlar', unit: ProductUnit.kg),
  CatalogProduct(id: 'v010', name: 'Ko‘katlar', category: 'Sabzavotlar', unit: ProductUnit.boglam),

  // Mevalar
  CatalogProduct(id: 'f001', name: 'Olma', category: 'Mevalar', unit: ProductUnit.kg),
  CatalogProduct(id: 'f002', name: 'Banan', category: 'Mevalar', unit: ProductUnit.kg),
  CatalogProduct(id: 'f003', name: 'Apelsin', category: 'Mevalar', unit: ProductUnit.kg),
  CatalogProduct(id: 'f004', name: 'Mandarin', category: 'Mevalar', unit: ProductUnit.kg),
  CatalogProduct(id: 'f005', name: 'Uzum', category: 'Mevalar', unit: ProductUnit.kg),
  CatalogProduct(id: 'f006', name: 'Tarvuz', category: 'Mevalar', unit: ProductUnit.kg),
  CatalogProduct(id: 'f007', name: 'Qovun', category: 'Mevalar', unit: ProductUnit.kg),
  CatalogProduct(id: 'f008', name: 'Nok', category: 'Mevalar', unit: ProductUnit.kg),
  CatalogProduct(id: 'f009', name: 'Limon', category: 'Mevalar', unit: ProductUnit.kg),

  // Go‘sht va sut
  CatalogProduct(id: 'd001', name: 'Mol go‘shti', category: 'Go‘sht va sut', unit: ProductUnit.kg),
  CatalogProduct(id: 'd002', name: 'Qo‘y go‘shti', category: 'Go‘sht va sut', unit: ProductUnit.kg),
  CatalogProduct(id: 'd003', name: 'Tovuq go‘shti', category: 'Go‘sht va sut', unit: ProductUnit.kg),
  CatalogProduct(id: 'd004', name: 'Sut', category: 'Go‘sht va sut', unit: ProductUnit.litr),
  CatalogProduct(id: 'd005', name: 'Qatiq', category: 'Go‘sht va sut', unit: ProductUnit.litr),
  CatalogProduct(id: 'd006', name: 'Smetana', category: 'Go‘sht va sut', unit: ProductUnit.quti),
  CatalogProduct(id: 'd007', name: 'Pishloq', category: 'Go‘sht va sut', unit: ProductUnit.kg),
  CatalogProduct(id: 'd008', name: 'Sariyog‘', category: 'Go‘sht va sut', unit: ProductUnit.pachka),

  // Ichimliklar
  CatalogProduct(id: 'b001', name: 'Ichimlik suvi', category: 'Ichimliklar', unit: ProductUnit.litr),
  CatalogProduct(id: 'b002', name: 'Gazli ichimlik', category: 'Ichimliklar', unit: ProductUnit.litr),
  CatalogProduct(id: 'b003', name: 'Sharbat', category: 'Ichimliklar', unit: ProductUnit.litr),
  CatalogProduct(id: 'b004', name: 'Energetik ichimlik', category: 'Ichimliklar', unit: ProductUnit.dona),

  // Maishiy kimyo
  CatalogProduct(id: 'h001', name: 'Kir yuvish kukuni', category: 'Maishiy kimyo', unit: ProductUnit.kg),
  CatalogProduct(id: 'h002', name: 'Idish yuvish vositasi', category: 'Maishiy kimyo', unit: ProductUnit.dona),
  CatalogProduct(id: 'h003', name: 'Oqartirgich', category: 'Maishiy kimyo', unit: ProductUnit.litr),
  CatalogProduct(id: 'h004', name: 'Pol yuvish vositasi', category: 'Maishiy kimyo', unit: ProductUnit.litr),
  CatalogProduct(id: 'h005', name: 'Sovun', category: 'Maishiy kimyo', unit: ProductUnit.dona),
  CatalogProduct(id: 'h006', name: 'Shampun', category: 'Maishiy kimyo', unit: ProductUnit.dona),
  CatalogProduct(id: 'h007', name: 'Tish pastasi', category: 'Maishiy kimyo', unit: ProductUnit.dona),

  // Uy-ro‘zg‘or
  CatalogProduct(id: 'u001', name: 'Axlat paketi', category: 'Uy-ro‘zg‘or', unit: ProductUnit.pachka),
  CatalogProduct(id: 'u002', name: 'Hojatxona qog‘ozi', category: 'Uy-ro‘zg‘or', unit: ProductUnit.dona),
  CatalogProduct(id: 'u003', name: 'Qog‘oz salfetka', category: 'Uy-ro‘zg‘or', unit: ProductUnit.pachka),
  CatalogProduct(id: 'u004', name: 'Oshxona sochiq qog‘ozi', category: 'Uy-ro‘zg‘or', unit: ProductUnit.pachka),
  CatalogProduct(id: 'u005', name: 'Gugurt', category: 'Uy-ro‘zg‘or', unit: ProductUnit.quti),
  CatalogProduct(id: 'u006', name: 'Batareyka', category: 'Uy-ro‘zg‘or', unit: ProductUnit.dona),
];
