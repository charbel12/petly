-- CreateEnum
CREATE TYPE "PetType" AS ENUM ('dog', 'cat', 'bird', 'fish', 'rabbit', 'other');

-- CreateEnum
CREATE TYPE "ItemCategory" AS ENUM ('food', 'toys', 'cleaning', 'health', 'accessories', 'other');

-- CreateEnum
CREATE TYPE "FavoriteEntityType" AS ENUM ('store', 'vet');

-- AlterTable: convert pets.type from free-text VARCHAR to the PetType enum.
-- A plain `ALTER COLUMN ... TYPE "PetType"` cast fails because existing values are
-- free-text strings ('Dog', 'Cat', ...), not enum labels, so backfill via a new
-- column + CASE mapping instead.
ALTER TABLE "pets" ADD COLUMN "type_new" "PetType" NOT NULL DEFAULT 'other';
UPDATE "pets" SET "type_new" = CASE
  WHEN lower(type) LIKE 'dog%' THEN 'dog'::"PetType"
  WHEN lower(type) LIKE 'cat%' THEN 'cat'::"PetType"
  WHEN lower(type) LIKE 'bird%' THEN 'bird'::"PetType"
  WHEN lower(type) LIKE 'fish%' THEN 'fish'::"PetType"
  WHEN lower(type) LIKE 'rabbit%' THEN 'rabbit'::"PetType"
  ELSE 'other'::"PetType"
END;
ALTER TABLE "pets" DROP COLUMN "type";
ALTER TABLE "pets" RENAME COLUMN "type_new" TO "type";

-- AlterTable
ALTER TABLE "store_items" ADD COLUMN     "category" "ItemCategory" NOT NULL DEFAULT 'other',
ADD COLUMN     "pet_types" "PetType"[] DEFAULT ARRAY[]::"PetType"[];

-- AlterTable
ALTER TABLE "stores" ADD COLUMN     "pet_types" "PetType"[] DEFAULT ARRAY[]::"PetType"[];

-- AlterTable
ALTER TABLE "vets" ADD COLUMN     "pet_types" "PetType"[] DEFAULT ARRAY[]::"PetType"[];

-- CreateTable
CREATE TABLE "favorites" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "entity_type" "FavoriteEntityType" NOT NULL,
    "entity_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "favorites_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "favorites_user_id_idx" ON "favorites"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "favorites_user_id_entity_type_entity_id_key" ON "favorites"("user_id", "entity_type", "entity_id");

-- AddForeignKey
ALTER TABLE "favorites" ADD CONSTRAINT "favorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
