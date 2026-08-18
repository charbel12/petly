-- CreateEnum
CREATE TYPE "ListingStatus" AS ENUM ('pending', 'approved', 'rejected');

-- AlterTable
ALTER TABLE "vets"
ADD COLUMN "owner_user_id" UUID,
ADD COLUMN "status" "ListingStatus" NOT NULL DEFAULT 'approved',
ADD COLUMN "rejection_reason" VARCHAR(500),
ADD COLUMN "submitted_at" TIMESTAMPTZ,
ADD COLUMN "reviewed_at" TIMESTAMPTZ,
ADD COLUMN "reviewer_id" UUID,
ADD COLUMN "hours" JSONB;

-- AlterTable
ALTER TABLE "stores"
ADD COLUMN "services" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
ADD COLUMN "owner_user_id" UUID,
ADD COLUMN "status" "ListingStatus" NOT NULL DEFAULT 'approved',
ADD COLUMN "rejection_reason" VARCHAR(500),
ADD COLUMN "submitted_at" TIMESTAMPTZ,
ADD COLUMN "reviewed_at" TIMESTAMPTZ,
ADD COLUMN "reviewer_id" UUID,
ADD COLUMN "hours" JSONB;

-- CreateIndex
CREATE INDEX "vets_status_idx" ON "vets"("status");

-- CreateIndex
CREATE INDEX "vets_owner_user_id_idx" ON "vets"("owner_user_id");

-- CreateIndex
CREATE INDEX "stores_status_idx" ON "stores"("status");

-- CreateIndex
CREATE INDEX "stores_owner_user_id_idx" ON "stores"("owner_user_id");

-- AddForeignKey
ALTER TABLE "vets" ADD CONSTRAINT "vets_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vets" ADD CONSTRAINT "vets_reviewer_id_fkey" FOREIGN KEY ("reviewer_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stores" ADD CONSTRAINT "stores_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stores" ADD CONSTRAINT "stores_reviewer_id_fkey" FOREIGN KEY ("reviewer_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
