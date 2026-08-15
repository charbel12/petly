import { prisma, deployMigrations, disconnectPrisma } from '../src/db/prisma';
import { ensureAdmin } from '../src/modules/auth/auth.service';

const DEMO_USER_ID = '11111111-1111-1111-1111-111111111111';

async function seed() {
  deployMigrations();
  await prisma.$connect();

  await ensureAdmin();
  console.log('✓ Admin account ensured');

  const existingVets = await prisma.vet.count();
  if (existingVets > 0) {
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
      },
    ],
  });

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
