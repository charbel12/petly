import { prisma } from './prisma';
import { ItemCategory } from '../modules/stores/stores.types';
import { PetType } from '../modules/vets/vets.types';

const STORE_ITEMS: Record<
  string,
  Array<{
    name: string;
    description: string;
    price: number;
    currency: 'USD';
    sortOrder: number;
    category: ItemCategory;
    petTypes: PetType[];
  }>
> = {
  'Pet World Lebanon': [
    {
      name: 'Premium dog food 12kg',
      description: 'Complete dry food for adult dogs.',
      price: 42,
      currency: 'USD',
      sortOrder: 1,
      category: 'food',
      petTypes: ['dog'],
    },
    {
      name: 'Clumping cat litter',
      description: 'Low-dust litter, 10L bag.',
      price: 8,
      currency: 'USD',
      sortOrder: 2,
      category: 'cleaning',
      petTypes: ['cat'],
    },
    {
      name: 'Rubber chew toy',
      description: 'Durable toy for medium dogs.',
      price: 6,
      currency: 'USD',
      sortOrder: 3,
      category: 'toys',
      petTypes: ['dog'],
    },
    {
      name: 'Adjustable nylon collar',
      description: 'Fits small to medium pets.',
      price: 11,
      currency: 'USD',
      sortOrder: 4,
      category: 'accessories',
      petTypes: ['dog', 'cat'],
    },
  ],
  'Bark & Meow Supplies': [
    {
      name: 'Puppy kibble 3kg',
      description: 'Starter formula for puppies.',
      price: 18.5,
      currency: 'USD',
      sortOrder: 1,
      category: 'food',
      petTypes: ['dog'],
    },
    {
      name: 'Salmon cat treats',
      description: 'Soft treats for training.',
      price: 5,
      currency: 'USD',
      sortOrder: 2,
      category: 'food',
      petTypes: ['cat'],
    },
    {
      name: 'Padded leash',
      description: '1.5m leash with comfortable grip.',
      price: 9,
      currency: 'USD',
      sortOrder: 3,
      category: 'accessories',
      petTypes: ['dog'],
    },
  ],
  'Aqua Pets Beirut': [
    {
      name: 'Tropical fish flakes',
      description: 'Daily flakes for community tanks.',
      price: 4,
      currency: 'USD',
      sortOrder: 1,
      category: 'food',
      petTypes: ['fish'],
    },
    {
      name: 'Hang-on aquarium filter',
      description: 'Quiet filter for 20–40L tanks.',
      price: 22,
      currency: 'USD',
      sortOrder: 2,
      category: 'accessories',
      petTypes: ['fish'],
    },
  ],
  'Farm & Fur Market': [
    {
      name: 'Timothy hay bale',
      description: 'Fresh hay for rabbits and guinea pigs.',
      price: 7,
      currency: 'USD',
      sortOrder: 1,
      category: 'food',
      petTypes: ['rabbit'],
    },
    {
      name: 'Rabbit pellets 2kg',
      description: 'Fortified pellets for small pets.',
      price: 10,
      currency: 'USD',
      sortOrder: 2,
      category: 'food',
      petTypes: ['rabbit'],
    },
  ],
  'Groom & Glow Salon': [
    {
      name: 'Oatmeal pet shampoo',
      description: 'Gentle wash for sensitive skin.',
      price: 14,
      currency: 'USD',
      sortOrder: 1,
      category: 'cleaning',
      petTypes: [],
    },
    {
      name: 'Nail clippers',
      description: 'Safety-guard clippers for cats and dogs.',
      price: 8,
      currency: 'USD',
      sortOrder: 2,
      category: 'health',
      petTypes: ['dog', 'cat'],
    },
  ],
};

/** Idempotent demo catalog for seeded stores. Safe to run on every boot. */
export async function ensureStoreItems() {
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
      if (existing) {
        // Keep older environments' demo rows (created before category/pet_types
        // existed) in sync with the current catalog data.
        await prisma.storeItem.update({
          where: { id: existing.id },
          data: { category: item.category, petTypes: item.petTypes },
        });
        continue;
      }
      await prisma.storeItem.create({
        data: {
          storeId: store.id,
          name: item.name,
          description: item.description,
          price: item.price,
          currency: item.currency,
          inStock: true,
          sortOrder: item.sortOrder,
          category: item.category,
          petTypes: item.petTypes,
        },
      });
    }
  }
}
