import { prisma, deployMigrations, disconnectPrisma } from '../src/db/prisma';
import { ensureAdmin, ensurePartner } from '../src/modules/auth/auth.service';

const DEMO_USER_ID = '11111111-1111-1111-1111-111111111111';

const VET_IMAGES: Record<string, string> = {
  'Beirut Pet Care Clinic': 'asset:listings/vet_beirut_pet_care.jpg',
  'Paws & Claws Veterinary': 'asset:listings/vet_paws_claws.jpg',
  'Lebanon Animal Hospital': 'asset:listings/vet_lebanon_animal.jpg',
  'Happy Tails Vet Center': 'asset:listings/vet_happy_tails.jpg',
  'Mountain Pets Clinic': 'asset:listings/vet_mountain_pets.jpg',
  'Saida Veterinary Services': 'asset:listings/vet_saida.jpg',
};

const STORE_IMAGES: Record<string, string> = {
  'Pet World Lebanon': 'asset:listings/store_pet_world.jpg',
  'Bark & Meow Supplies': 'asset:listings/store_bark_meow.jpg',
  'Aqua Pets Beirut': 'asset:listings/store_aqua_pets.jpg',
  'Farm & Fur Market': 'asset:listings/store_farm_fur.jpg',
  'Groom & Glow Salon': 'asset:listings/store_groom_glow.jpg',
};

const STORE_ITEMS: Record<
  string,
  Array<{
    name: string;
    description: string;
    price: number;
    currency: 'USD';
    sortOrder: number;
  }>
> = {
  'Pet World Lebanon': [
    {
      name: 'Premium dog food 12kg',
      description: 'Complete dry food for adult dogs.',
      price: 42,
      currency: 'USD',
      sortOrder: 1,
    },
    {
      name: 'Clumping cat litter',
      description: 'Low-dust litter, 10L bag.',
      price: 8,
      currency: 'USD',
      sortOrder: 2,
    },
    {
      name: 'Rubber chew toy',
      description: 'Durable toy for medium dogs.',
      price: 6,
      currency: 'USD',
      sortOrder: 3,
    },
    {
      name: 'Adjustable nylon collar',
      description: 'Fits small to medium pets.',
      price: 11,
      currency: 'USD',
      sortOrder: 4,
    },
  ],
  'Bark & Meow Supplies': [
    {
      name: 'Puppy kibble 3kg',
      description: 'Starter formula for puppies.',
      price: 18.5,
      currency: 'USD',
      sortOrder: 1,
    },
    {
      name: 'Salmon cat treats',
      description: 'Soft treats for training.',
      price: 5,
      currency: 'USD',
      sortOrder: 2,
    },
    {
      name: 'Padded leash',
      description: '1.5m leash with comfortable grip.',
      price: 9,
      currency: 'USD',
      sortOrder: 3,
    },
  ],
  'Aqua Pets Beirut': [
    {
      name: 'Tropical fish flakes',
      description: 'Daily flakes for community tanks.',
      price: 4,
      currency: 'USD',
      sortOrder: 1,
    },
    {
      name: 'Hang-on aquarium filter',
      description: 'Quiet filter for 20–40L tanks.',
      price: 22,
      currency: 'USD',
      sortOrder: 2,
    },
  ],
  'Farm & Fur Market': [
    {
      name: 'Timothy hay bale',
      description: 'Fresh hay for rabbits and guinea pigs.',
      price: 7,
      currency: 'USD',
      sortOrder: 1,
    },
    {
      name: 'Rabbit pellets 2kg',
      description: 'Fortified pellets for small pets.',
      price: 10,
      currency: 'USD',
      sortOrder: 2,
    },
  ],
  'Groom & Glow Salon': [
    {
      name: 'Oatmeal pet shampoo',
      description: 'Gentle wash for sensitive skin.',
      price: 14,
      currency: 'USD',
      sortOrder: 1,
    },
    {
      name: 'Nail clippers',
      description: 'Safety-guard clippers for cats and dogs.',
      price: 8,
      currency: 'USD',
      sortOrder: 2,
    },
  ],
};

async function backfillListingImages() {
  for (const [name, imageUrl] of Object.entries(VET_IMAGES)) {
    await prisma.vet.updateMany({ where: { name }, data: { imageUrl } });
  }
  for (const [name, imageUrl] of Object.entries(STORE_IMAGES)) {
    await prisma.store.updateMany({ where: { name }, data: { imageUrl } });
  }
  console.log('✓ Listing photos backfilled');
}

async function ensureStoreItems() {
  for (const [storeName, items] of Object.entries(STORE_ITEMS)) {
    const store = await prisma.store.findFirst({
      where: { name: storeName },
      select: { id: true },
    });
    if (!store) continue;
    for (const item of items) {
      const existing = await prisma.storeItem.findFirst({
        where: { storeId: store.id, name: item.name },
        select: { id: true },
      });
      if (existing) continue;
      await prisma.storeItem.create({
        data: {
          storeId: store.id,
          name: item.name,
          description: item.description,
          price: item.price,
          currency: item.currency,
          inStock: true,
          sortOrder: item.sortOrder,
        },
      });
    }
  }
  console.log('✓ Store items ensured');
}

async function ensurePendingDemoListing(partnerId: string) {
  const pendingName = 'Pending Partner Clinic';
  const existingPending = await prisma.vet.findFirst({
    where: { name: pendingName, ownerUserId: partnerId },
  });
  if (existingPending) return;
  await prisma.vet.create({
    data: {
      name: pendingName,
      phone: '96171109901',
      location: 'Hamra, Beirut',
      latitude: 33.8972,
      longitude: 35.4822,
      services: ['General checkup'],
      isEmergency: false,
      isOpenNow: true,
      featured: false,
      verified: false,
      ownerUserId: partnerId,
      status: 'pending',
      submittedAt: new Date(),
      hours: {
        timezone: 'Asia/Beirut',
        weekly: [
          { day: 0, closed: true },
          { day: 1, open: '09:00', close: '18:00' },
          { day: 2, open: '09:00', close: '18:00' },
          { day: 3, open: '09:00', close: '18:00' },
          { day: 4, open: '09:00', close: '18:00' },
          { day: 5, open: '09:00', close: '18:00' },
          { day: 6, open: '09:00', close: '14:00' },
        ],
      },
    },
  });
  console.log('✓ Demo pending listing ensured');
}

async function seed() {
  deployMigrations();
  await prisma.$connect();

  await ensureAdmin();
  console.log('✓ Admin account ensured');

  const partner = await ensurePartner();
  console.log('✓ Partner account ensured');

  const catalogExists = await prisma.vet.findFirst({
    where: { name: 'Beirut Pet Care Clinic' },
    select: { id: true },
  });
  if (catalogExists) {
    await backfillListingImages();
    await ensureStoreItems();
    await ensurePendingDemoListing(partner.id);
    console.log('✓ Seed skipped — data already present');
    return;
  }

  await prisma.user.upsert({
    where: { id: DEMO_USER_ID },
    update: {},
    create: {
      id: DEMO_USER_ID,
      name: 'Demo User',
      phone: '+96171123456',
      deviceId: null,
    },
  });

  await prisma.pet.createMany({
    data: [
      { userId: DEMO_USER_ID, name: 'Max', type: 'Dog', age: 3 },
      { userId: DEMO_USER_ID, name: 'Luna', type: 'Cat', age: 2 },
    ],
  });

  await prisma.vet.createMany({
    data: [
      {
        name: 'Beirut Pet Care Clinic',
        phone: '96171100001',
        location: 'Hamra, Beirut',
        latitude: 33.8972,
        longitude: 35.4822,
        services: ['General checkup', 'Vaccination', 'Emergency', 'Surgery'],
        verified: true,
        isEmergency: true,
        isOpenNow: true,
        featured: true,
        imageUrl: VET_IMAGES['Beirut Pet Care Clinic'],
      },
      {
        name: 'Paws & Claws Veterinary',
        phone: '96171100002',
        location: 'Achrafieh, Beirut',
        latitude: 33.8886,
        longitude: 35.5194,
        services: ['Dental care', 'Vaccination', 'Grooming consult'],
        verified: true,
        isEmergency: false,
        isOpenNow: true,
        featured: true,
        imageUrl: VET_IMAGES['Paws & Claws Veterinary'],
      },
      {
        name: 'Lebanon Animal Hospital',
        phone: '96171100003',
        location: 'Jounieh',
        latitude: 33.9808,
        longitude: 35.6178,
        services: ['Emergency', 'Surgery', 'X-ray', 'Lab tests'],
        verified: true,
        isEmergency: true,
        isOpenNow: true,
        featured: false,
        imageUrl: VET_IMAGES['Lebanon Animal Hospital'],
      },
      {
        name: 'Happy Tails Vet Center',
        phone: '96171100004',
        location: 'Verdun, Beirut',
        latitude: 33.8869,
        longitude: 35.4831,
        services: ['General checkup', 'Vaccination', 'Nutrition'],
        verified: true,
        isEmergency: false,
        isOpenNow: false,
        featured: false,
        imageUrl: VET_IMAGES['Happy Tails Vet Center'],
      },
      {
        name: 'Mountain Pets Clinic',
        phone: '96171100005',
        location: 'Broummana',
        latitude: 33.885,
        longitude: 35.628,
        services: ['General checkup', 'Emergency', 'Boarding consult'],
        verified: true,
        isEmergency: true,
        isOpenNow: true,
        featured: false,
        imageUrl: VET_IMAGES['Mountain Pets Clinic'],
      },
      {
        name: 'Saida Veterinary Services',
        phone: '96171100006',
        location: 'Saida',
        latitude: 33.5571,
        longitude: 35.3729,
        services: ['Vaccination', 'Surgery', 'Pet passport'],
        verified: false,
        isEmergency: false,
        isOpenNow: true,
        featured: false,
        imageUrl: VET_IMAGES['Saida Veterinary Services'],
      },
    ],
  });

  await prisma.store.createMany({
    data: [
      {
        name: 'Pet World Lebanon',
        type: 'Pet Store',
        location: 'Hamra, Beirut',
        phone: '96171110001',
        latitude: 33.8965,
        longitude: 35.481,
        featured: true,
        isOpenNow: true,
        imageUrl: STORE_IMAGES['Pet World Lebanon'],
      },
      {
        name: 'Bark & Meow Supplies',
        type: 'Pet Store',
        location: 'Achrafieh, Beirut',
        phone: '96171110002',
        latitude: 33.889,
        longitude: 35.52,
        featured: true,
        isOpenNow: true,
        imageUrl: STORE_IMAGES['Bark & Meow Supplies'],
      },
      {
        name: 'Aqua Pets Beirut',
        type: 'Aquarium',
        location: 'Verdun, Beirut',
        phone: '96171110003',
        latitude: 33.8875,
        longitude: 35.484,
        featured: false,
        isOpenNow: true,
        imageUrl: STORE_IMAGES['Aqua Pets Beirut'],
      },
      {
        name: 'Farm & Fur Market',
        type: 'Pet Store',
        location: 'Jounieh',
        phone: '96171110004',
        latitude: 33.9815,
        longitude: 35.6185,
        featured: false,
        isOpenNow: false,
        imageUrl: STORE_IMAGES['Farm & Fur Market'],
      },
      {
        name: 'Groom & Glow Salon',
        type: 'Grooming',
        location: 'Dbayeh',
        phone: '96171110005',
        latitude: 33.94,
        longitude: 35.59,
        featured: true,
        isOpenNow: true,
        imageUrl: STORE_IMAGES['Groom & Glow Salon'],
      },
    ],
  });

  await backfillListingImages();
  await ensureStoreItems();
  await ensurePendingDemoListing(partner.id);
  console.log('✓ Seed data inserted');
}

if (require.main === module) {
  seed()
    .then(() => disconnectPrisma())
    .then(() => process.exit(0))
    .catch(async (err) => {
      console.error('Seed failed:', err);
      await disconnectPrisma();
      process.exit(1);
    });
}

export { seed };
