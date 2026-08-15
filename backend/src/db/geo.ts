/** Shared geo helpers for nearby sorting (Prisma fetches, app sorts). */

export function haversineKm(
  lat1: number,
  lng1: number,
  lat2: number | null | undefined,
  lng2: number | null | undefined,
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

type GeoRow = {
  latitude: number | null;
  longitude: number | null;
  featured: boolean;
  name: string;
};

export function withDistance<T extends GeoRow>(
  rows: T[],
  lat?: number,
  lng?: number,
  maxDistanceKm?: number,
): Array<T & { distance_km: number | null }> {
  const hasGeo = lat !== undefined && lng !== undefined;

  let mapped = rows.map((row) => ({
    ...row,
    distance_km: hasGeo ? haversineKm(lat, lng, row.latitude, row.longitude) : null,
  }));

  if (maxDistanceKm !== undefined && hasGeo) {
    mapped = mapped.filter(
      (r) => r.distance_km != null && r.distance_km <= maxDistanceKm,
    );
  }

  mapped.sort((a, b) => {
    if (hasGeo) {
      if (a.distance_km == null && b.distance_km != null) return 1;
      if (a.distance_km != null && b.distance_km == null) return -1;
      if (
        a.distance_km != null &&
        b.distance_km != null &&
        a.distance_km !== b.distance_km
      ) {
        return a.distance_km - b.distance_km;
      }
    }
    if (a.featured !== b.featured) return a.featured ? -1 : 1;
    return a.name.localeCompare(b.name);
  });

  return mapped;
}
