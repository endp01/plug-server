-- CreateTable
CREATE TABLE "Address" (
    "id" TEXT NOT NULL PRIMARY KEY
);

-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_SignedPermission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "permissionId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "intentId" TEXT,
    "addressId" TEXT,
    CONSTRAINT "SignedPermission_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedPermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedPermission_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Intent" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "SignedPermission_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_SignedPermission" ("domainId", "id", "intentId", "permissionId", "signature") SELECT "domainId", "id", "intentId", "permissionId", "signature" FROM "SignedPermission";
DROP TABLE "SignedPermission";
ALTER TABLE "new_SignedPermission" RENAME TO "SignedPermission";
CREATE TABLE "new_SignedIntents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT,
    CONSTRAINT "SignedIntents_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedIntents_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_SignedIntents" ("domainId", "id", "signature") SELECT "domainId", "id", "signature" FROM "SignedIntents";
DROP TABLE "SignedIntents";
ALTER TABLE "new_SignedIntents" RENAME TO "SignedIntents";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
