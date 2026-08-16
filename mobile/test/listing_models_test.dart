import 'package:flutter_test/flutter_test.dart';
import 'package:petly/core/widgets/listing_image.dart';
import 'package:petly/data/models/store.dart';
import 'package:petly/data/models/vet.dart';

void main() {
  group('ListingImageSource', () {
    test('resolves bundled asset: URLs', () {
      expect(
        ListingImageSource.assetPath('asset:listings/vet_beirut_pet_care.jpg'),
        'assets/listings/vet_beirut_pet_care.jpg',
      );
      expect(ListingImageSource.isAsset('asset:listings/foo.jpg'), isTrue);
      expect(ListingImageSource.isNetwork('https://cdn.example/x.jpg'), isTrue);
      expect(ListingImageSource.assetPath('https://cdn.example/x.jpg'), isNull);
      expect(ListingImageSource.assetPath(null), isNull);
    });
  });

  group('listing models', () {
    test('Vet.distanceAndLocation joins distance and area', () {
      const vet = Vet(
        id: '1',
        name: 'Beirut Pet Care Clinic',
        phone: '96171100001',
        location: 'Hamra, Beirut',
        services: ['Emergency', 'Surgery'],
        verified: true,
        isEmergency: true,
        isOpenNow: true,
        featured: true,
        imageUrl: 'asset:listings/vet_beirut_pet_care.jpg',
        distanceKm: 1.2,
      );
      expect(vet.distanceAndLocation, '1.2 km away · Hamra, Beirut');
      expect(vet.heroTag, 'vet-1');
    });

    test('Store.fromJson reads image_url', () {
      final store = Store.fromJson({
        'id': 's1',
        'name': 'Pet World Lebanon',
        'type': 'Pet Store',
        'location': 'Hamra, Beirut',
        'phone': '96171110001',
        'featured': true,
        'is_open_now': true,
        'image_url': 'asset:listings/store_pet_world.jpg',
        'distance_km': 0.4,
      });
      expect(store.imageUrl, 'asset:listings/store_pet_world.jpg');
      expect(store.distanceAndLocation, '400 m away · Hamra, Beirut');
    });
  });
}
