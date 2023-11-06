/*
  Warnings:

  - Made the column `addressId` on table `SignedPermission` required. This step will fail if there are existing NULL values in that column.
  - Made the column `addressId` on table `SignedIntents` required. This step will fail if there are existing NULL values in that column.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_SignedPermission" (
    "permissionId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT NOT NULL,

    PRIMARY KEY ("permissionId", "signature"),
    CONSTRAINT "SignedPermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedPermission_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_SignedPermission" ("addressId", "permissionId", "signature") SELECT "addressId", "permissionId", "signature" FROM "SignedPermission";
DROP TABLE "SignedPermission";
ALTER TABLE "new_SignedPermission" RENAME TO "SignedPermission";
CREATE TABLE "new_SignedIntents" (
    "intentsId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT NOT NULL,

    PRIMARY KEY ("intentsId", "signature"),
    CONSTRAINT "SignedIntents_intentsId_fkey" FOREIGN KEY ("intentsId") REFERENCES "Intents" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedIntents_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_SignedIntents" ("addressId", "intentsId", "signature") SELECT "addressId", "intentsId", "signature" FROM "SignedIntents";
DROP TABLE "SignedIntents";
ALTER TABLE "new_SignedIntents" RENAME TO "SignedIntents";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
