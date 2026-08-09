import { User, CreateUserDto } from '../modules/users/users.types';
import { Pet, CreatePetDto, UpdatePetDto } from '../modules/pets/pets.types';
import { Vet, VetFilters } from '../modules/vets/vets.types';
import { Store, StoreFilters } from '../modules/stores/stores.types';
import {
  ClickStats,
  TrackWhatsAppClickDto,
  WhatsAppClick,
} from '../modules/analytics/analytics.types';
import { AppError } from '../middleware/errorHandler';
import { randomUUID } from 'crypto';

function haversineKm(
  lat1: number,
  lng1: number,
  lat2: number | null,
  lng2: number | null,
): number | null {
  if (lat2 == null || lng2 == null) return null;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function now() {
  return new Date();
}

class MemoryStore {
  users: User[] = [];
  pets: Pet[] = [];
  vets: Vet[] = [];
  stores: Store[] = [];
  whatsappClicks: WhatsAppClick[] = [];

  seed() {
    if (this.vets.length > 0) return;

    this.users.push({
      id: '11111111-1111-1111-1111-111111111111',
      name: 'Demo User',
      phone: '+96171123456',
      device_id: null,
      created_at: now(),
      updated_at: now(),
    });

    this.pets.push(
      {
        id: randomUUID(),
        user_id: '11111111-1111-1111-1111-111111111111',
        name: 'Max',
        type: 'Dog',
        age: 3,
        created_at: now(),
        updated_at: now(),
      },
      {
        id: randomUUID(),
        user_id: '11111111-1111-1111-1111-111111111111',
        name: 'Luna',
        type: 'Cat',
        age: 2,
        created_at: now(),
        updated_at: now(),
      },
    );

    const vetSeed: Omit<Vet, 'id' | 'created_at' | 'updated_at' | 'distance_km'>[] = [
      {
        name: 'Beirut Pet Care Clinic',
        phone: '96171100001',
        location: 'Hamra, Beirut',
        latitude: 33.8972,
        longitude: 35.4822,
        services: ['General checkup', 'Vaccination', 'Emergency', 'Surgery'],
        verified: true,
        is_emergency: true,
        is_open_now: true,
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
        is_emergency: false,
        is_open_now: true,
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
        is_emergency: true,
        is_open_now: true,
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
        is_emergency: false,
        is_open_now: false,
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
        is_emergency: true,
        is_open_now: true,
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
        is_emergency: false,
        is_open_now: true,
        featured: false,
      },
    ];

    this.vets = vetSeed.map((v) => ({
      ...v,
      id: randomUUID(),
      created_at: now(),
      updated_at: now(),
    }));

    const storeSeed: Omit<Store, 'id' | 'created_at' | 'updated_at' | 'distance_km'>[] = [
      {
        name: 'Pet World Lebanon',
        type: 'Pet Store',
        location: 'Hamra, Beirut',
        phone: '96171110001',
        latitude: 33.8965,
        longitude: 35.481,
        featured: true,
        is_open_now: true,
      },
      {
        name: 'Bark & Meow Supplies',
        type: 'Pet Store',
        location: 'Achrafieh, Beirut',
        phone: '96171110002',
        latitude: 33.889,
        longitude: 35.52,
        featured: true,
        is_open_now: true,
      },
      {
        name: 'Aqua Pets Beirut',
        type: 'Aquarium',
        location: 'Verdun, Beirut',
        phone: '96171110003',
        latitude: 33.8875,
        longitude: 35.484,
        featured: false,
        is_open_now: true,
      },
      {
        name: 'Farm & Fur Market',
        type: 'Pet Store',
        location: 'Jounieh',
        phone: '96171110004',
        latitude: 33.9815,
        longitude: 35.6185,
        featured: false,
        is_open_now: false,
      },
      {
        name: 'Groom & Glow Salon',
        type: 'Grooming',
        location: 'Dbayeh',
        phone: '96171110005',
        latitude: 33.94,
        longitude: 35.59,
        featured: true,
        is_open_now: true,
      },
    ];

    this.stores = storeSeed.map((s) => ({
      ...s,
      id: randomUUID(),
      created_at: now(),
      updated_at: now(),
    }));
  }

  createUser(dto: CreateUserDto): User {
    if (!dto.name?.trim() || !dto.phone?.trim()) {
      throw new AppError(400, 'name and phone are required');
    }

    const deviceId = dto.device_id?.trim() || null;

    if (deviceId) {
      const byDevice = this.users.find((u) => u.device_id === deviceId);
      if (byDevice) {
        byDevice.name = dto.name.trim();
        byDevice.phone = dto.phone.trim();
        byDevice.updated_at = now();
        return byDevice;
      }
    }

    const existing = this.users.find((u) => u.phone === dto.phone.trim());
    if (existing) {
      existing.name = dto.name.trim();
      if (deviceId) existing.device_id = deviceId;
      existing.updated_at = now();
      return existing;
    }

    const user: User = {
      id: randomUUID(),
      name: dto.name.trim(),
      phone: dto.phone.trim(),
      device_id: deviceId,
      created_at: now(),
      updated_at: now(),
    };
    this.users.push(user);
    return user;
  }

  getUser(id: string): User {
    const user = this.users.find((u) => u.id === id);
    if (!user) throw new AppError(404, 'User not found');
    return user;
  }

  getUserByDeviceId(deviceId: string): User | null {
    return this.users.find((u) => u.device_id === deviceId) ?? null;
  }

  listUsers(): User[] {
    return [...this.users].sort(
      (a, b) => b.created_at.getTime() - a.created_at.getTime(),
    );
  }

  createPet(dto: CreatePetDto): Pet {
    if (!dto.user_id || !dto.name?.trim() || !dto.type?.trim()) {
      throw new AppError(400, 'user_id, name, and type are required');
    }
    const age = Number(dto.age);
    if (Number.isNaN(age) || age < 0) {
      throw new AppError(400, 'age must be a non-negative number');
    }
    const pet: Pet = {
      id: randomUUID(),
      user_id: dto.user_id,
      name: dto.name.trim(),
      type: dto.type.trim(),
      age,
      created_at: now(),
      updated_at: now(),
    };
    this.pets.push(pet);
    return pet;
  }

  listPets(userId: string): Pet[] {
    return this.pets
      .filter((p) => p.user_id === userId)
      .sort((a, b) => b.created_at.getTime() - a.created_at.getTime());
  }

  getPet(id: string): Pet {
    const pet = this.pets.find((p) => p.id === id);
    if (!pet) throw new AppError(404, 'Pet not found');
    return pet;
  }

  updatePet(id: string, dto: UpdatePetDto): Pet {
    const pet = this.getPet(id);
    if (dto.name?.trim()) pet.name = dto.name.trim();
    if (dto.type?.trim()) pet.type = dto.type.trim();
    if (dto.age !== undefined) {
      const age = Number(dto.age);
      if (Number.isNaN(age) || age < 0) {
        throw new AppError(400, 'age must be a non-negative number');
      }
      pet.age = age;
    }
    pet.updated_at = now();
    return pet;
  }

  deletePet(id: string): void {
    const idx = this.pets.findIndex((p) => p.id === id);
    if (idx === -1) throw new AppError(404, 'Pet not found');
    this.pets.splice(idx, 1);
  }

  listVets(filters: VetFilters = {}): Vet[] {
    let rows = this.vets.map((v) => ({
      ...v,
      distance_km:
        filters.lat !== undefined && filters.lng !== undefined
          ? haversineKm(filters.lat, filters.lng, v.latitude, v.longitude)
          : null,
    }));

    if (filters.search?.trim()) {
      const q = filters.search.trim().toLowerCase();
      rows = rows.filter(
        (v) =>
          v.name.toLowerCase().includes(q) ||
          v.location.toLowerCase().includes(q),
      );
    }
    if (filters.open_now) rows = rows.filter((v) => v.is_open_now);
    if (filters.emergency) rows = rows.filter((v) => v.is_emergency);
    if (filters.verified) rows = rows.filter((v) => v.verified);
    if (filters.featured) rows = rows.filter((v) => v.featured);
    if (filters.max_distance_km !== undefined) {
      rows = rows.filter(
        (v) =>
          v.distance_km != null && v.distance_km <= filters.max_distance_km!,
      );
    }

    rows.sort((a, b) => {
      if (a.distance_km != null && b.distance_km != null) {
        return a.distance_km - b.distance_km;
      }
      if (a.featured !== b.featured) return a.featured ? -1 : 1;
      return a.name.localeCompare(b.name);
    });

    return rows;
  }

  getVet(id: string, lat?: number, lng?: number): Vet {
    const vet = this.vets.find((v) => v.id === id);
    if (!vet) throw new AppError(404, 'Vet not found');
    return {
      ...vet,
      distance_km:
        lat !== undefined && lng !== undefined
          ? haversineKm(lat, lng, vet.latitude, vet.longitude)
          : null,
    };
  }

  listStores(filters: StoreFilters = {}): Store[] {
    let rows = this.stores.map((s) => ({
      ...s,
      distance_km:
        filters.lat !== undefined && filters.lng !== undefined
          ? haversineKm(filters.lat, filters.lng, s.latitude, s.longitude)
          : null,
    }));

    if (filters.search?.trim()) {
      const q = filters.search.trim().toLowerCase();
      rows = rows.filter(
        (s) =>
          s.name.toLowerCase().includes(q) ||
          s.location.toLowerCase().includes(q),
      );
    }
    if (filters.type?.trim()) {
      const t = filters.type.trim().toLowerCase();
      rows = rows.filter((s) => s.type.toLowerCase() === t);
    }
    if (filters.open_now) rows = rows.filter((s) => s.is_open_now);
    if (filters.featured) rows = rows.filter((s) => s.featured);
    if (filters.max_distance_km !== undefined) {
      rows = rows.filter(
        (s) =>
          s.distance_km != null && s.distance_km <= filters.max_distance_km!,
      );
    }

    rows.sort((a, b) => {
      if (a.distance_km != null && b.distance_km != null) {
        return a.distance_km - b.distance_km;
      }
      if (a.featured !== b.featured) return a.featured ? -1 : 1;
      return a.name.localeCompare(b.name);
    });

    return rows;
  }

  getStore(id: string, lat?: number, lng?: number): Store {
    const store = this.stores.find((s) => s.id === id);
    if (!store) throw new AppError(404, 'Store not found');
    return {
      ...store,
      distance_km:
        lat !== undefined && lng !== undefined
          ? haversineKm(lat, lng, store.latitude, store.longitude)
          : null,
    };
  }

  trackWhatsAppClick(dto: TrackWhatsAppClickDto): WhatsAppClick {
    const click: WhatsAppClick = {
      id: randomUUID(),
      entity_type: dto.entity_type,
      entity_id: dto.entity_id ?? null,
      user_id: dto.user_id ?? null,
      device_id: dto.device_id ?? null,
      source: dto.source ?? null,
      created_at: now(),
    };
    this.whatsappClicks.push(click);
    return click;
  }

  getClickStats(): ClickStats {
    const by_entity_type: Record<string, number> = {};
    for (const click of this.whatsappClicks) {
      by_entity_type[click.entity_type] =
        (by_entity_type[click.entity_type] ?? 0) + 1;
    }
    const recent = [...this.whatsappClicks]
      .sort((a, b) => b.created_at.getTime() - a.created_at.getTime())
      .slice(0, 20);
    return {
      total: this.whatsappClicks.length,
      by_entity_type,
      recent,
    };
  }
}

export const memoryStore = new MemoryStore();
