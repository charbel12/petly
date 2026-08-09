import { query } from './pool';
import { migrate } from './migrate';

async function seed() {
  await migrate();

  const { rows: existingVets } = await query<{ count: string }>(
    'SELECT COUNT(*)::text AS count FROM vets',
  );
  if (Number(existingVets[0]?.count) > 0) {
    console.log('✓ Seed skipped — data already present');
    return;
  }

  await query(
    `INSERT INTO users (id, name, phone, device_id) VALUES
      ('11111111-1111-1111-1111-111111111111', 'Demo User', '+96171123456', NULL)
     ON CONFLICT (phone) DO NOTHING`,
  );

  await query(
    `INSERT INTO pets (user_id, name, type, age) VALUES
      ('11111111-1111-1111-1111-111111111111', 'Max', 'Dog', 3),
      ('11111111-1111-1111-1111-111111111111', 'Luna', 'Cat', 2)`,
  );

  await query(
    `INSERT INTO vets (name, phone, location, latitude, longitude, services, verified, is_emergency, is_open_now, featured) VALUES
      ('Beirut Pet Care Clinic', '96171100001', 'Hamra, Beirut', 33.8972, 35.4822,
        ARRAY['General checkup','Vaccination','Emergency','Surgery'], TRUE, TRUE, TRUE, TRUE),
      ('Paws & Claws Veterinary', '96171100002', 'Achrafieh, Beirut', 33.8886, 35.5194,
        ARRAY['Dental care','Vaccination','Grooming consult'], TRUE, FALSE, TRUE, TRUE),
      ('Lebanon Animal Hospital', '96171100003', 'Jounieh', 33.9808, 35.6178,
        ARRAY['Emergency','Surgery','X-ray','Lab tests'], TRUE, TRUE, TRUE, FALSE),
      ('Happy Tails Vet Center', '96171100004', 'Verdun, Beirut', 33.8869, 35.4831,
        ARRAY['General checkup','Vaccination','Nutrition'], TRUE, FALSE, FALSE, FALSE),
      ('Mountain Pets Clinic', '96171100005', 'Broummana', 33.8850, 35.6280,
        ARRAY['General checkup','Emergency','Boarding consult'], TRUE, TRUE, TRUE, FALSE),
      ('Saida Veterinary Services', '96171100006', 'Saida', 33.5571, 35.3729,
        ARRAY['Vaccination','Surgery','Pet passport'], FALSE, FALSE, TRUE, FALSE)`,
  );

  await query(
    `INSERT INTO stores (name, type, location, phone, latitude, longitude, featured, is_open_now) VALUES
      ('Pet World Lebanon', 'Pet Store', 'Hamra, Beirut', '96171110001', 33.8965, 35.4810, TRUE, TRUE),
      ('Bark & Meow Supplies', 'Pet Store', 'Achrafieh, Beirut', '96171110002', 33.8890, 35.5200, TRUE, TRUE),
      ('Aqua Pets Beirut', 'Aquarium', 'Verdun, Beirut', '96171110003', 33.8875, 35.4840, FALSE, TRUE),
      ('Farm & Fur Market', 'Pet Store', 'Jounieh', '96171110004', 33.9815, 35.6185, FALSE, FALSE),
      ('Groom & Glow Salon', 'Grooming', 'Dbayeh', '96171110005', 33.9400, 35.5900, TRUE, TRUE)`,
  );

  console.log('✓ Seed data inserted');
}

if (require.main === module) {
  seed()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error('Seed failed:', err);
      process.exit(1);
    });
}

export { seed };
