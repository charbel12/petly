import 'package:flutter_test/flutter_test.dart';
import 'package:petly/core/widgets/listing_image.dart';
import 'package:petly/data/models/store.dart';
import 'package:petly/data/models/store_item.dart';
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

    test('Vet.fromJson reads status, hours, and rejection_reason', () {
      final vet = Vet.fromJson({
        'id': 'v2',
        'name': 'Pending Partner Clinic',
        'phone': '96171109901',
        'location': 'Hamra, Beirut',
        'services': ['General checkup'],
        'verified': false,
        'is_emergency': false,
        'is_open_now': true,
        'featured': false,
        'status': 'rejected',
        'rejection_reason': 'Need a clearer address',
        'hours': {
          'timezone': 'Asia/Beirut',
          'weekly': [
            {'day': 0, 'closed': true},
            {'day': 1, 'open': '09:00', 'close': '18:00'},
          ],
        },
      });
      expect(vet.status, 'rejected');
      expect(vet.rejectionReason, 'Need a clearer address');
      expect(vet.hours?.timezone, 'Asia/Beirut');
      expect(vet.hours?.entryFor(1).summary, '09:00–18:00');
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

    test('Store.fromJson reads services and hours when present', () {
      final store = Store.fromJson({
        'id': 's2',
        'name': 'Groom & Glow Salon',
        'type': 'Grooming',
        'location': 'Dbayeh',
        'featured': true,
        'is_open_now': true,
        'services': ['Bath', 'Haircut'],
        'status': 'approved',
        'hours': {
          'timezone': 'Asia/Beirut',
          'weekly': [
            {'day': 1, 'open': '10:00', 'close': '19:00'},
          ],
        },
      });
      expect(store.services, ['Bath', 'Haircut']);
      expect(store.status, 'approved');
      expect(store.hours?.entryFor(1).open, '10:00');
    });
  });

  group('store items', () {
    test('StoreItem.fromJson reads catalog fields and price labels', () {
      final item = StoreItem.fromJson({
        'id': 'i1',
        'store_id': 's1',
        'name': 'Premium dog food 12kg',
        'description': 'Complete dry food',
        'price': 42,
        'currency': 'USD',
        'in_stock': true,
        'sort_order': 1,
      });
      expect(item.storeId, 's1');
      expect(item.inStock, isTrue);
      expect(item.priceLabel, contains('42'));

      final lbp = StoreItem.fromJson({
        'id': 'i2',
        'store_id': 's1',
        'name': 'Cat litter',
        'price': 150000,
        'currency': 'LBP',
        'in_stock': false,
      });
      expect(lbp.priceLabel, 'LBP 150,000');
      expect(lbp.inStock, isFalse);

      final ask = StoreItem.fromJson({
        'id': 'i3',
        'store_id': 's1',
        'name': 'Ask about this toy',
        'currency': 'USD',
      });
      expect(ask.priceLabel, 'Ask in store');
    });

    test('NearestStoreItems.fromJson maps store and items', () {
      final payload = NearestStoreItems.fromJson({
        'store': {
          'id': 's1',
          'name': 'Pet World Lebanon',
          'type': 'Pet Store',
          'location': 'Hamra, Beirut',
          'featured': true,
          'is_open_now': true,
        },
        'items': [
          {
            'id': 'i1',
            'store_id': 's1',
            'name': 'Chew toy',
            'price': 6,
            'currency': 'USD',
            'in_stock': true,
          },
        ],
      });
      expect(payload.isEmpty, isFalse);
      expect(payload.store?.name, 'Pet World Lebanon');
      expect(payload.items, hasLength(1));
      expect(payload.items.first.name, 'Chew toy');
    });
  });
}
