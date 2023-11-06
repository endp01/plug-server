/*
  Warnings:

  - You are about to drop the column `domainId` on the `SignedPermission` table. All the data in the column will be lost.
  - You are about to drop the column `domainId` on the `SignedIntents` table. All the data in the column will be lost.
  - Added the required column `domainId` to the `Permission` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_SignedPermission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "permissionId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "intentId" TEXT,
    "addressId" TEXT,
    CONSTRAINT "SignedPermission_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "SignedPermission_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Intent" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "SignedPermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_SignedPermission" ("addressId", "id", "intentId", "permissionId", "signature") SELECT "addressId", "id", "intentId", "permissionId", "signature" FROM "SignedPermission";
DROP TABLE "SignedPermission";
ALTER TABLE "new_SignedPermission" RENAME TO "SignedPermission";
CREATE TABLE "new_Intent" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT,
    "transactionId" TEXT NOT NULL,
    "signedIntentsId" TEXT,
    CONSTRAINT "Intent_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "Intent_signedIntentsId_fkey" FOREIGN KEY ("signedIntentsId") REFERENCES "SignedIntents" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "Intent_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "Transaction" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Intent" ("id", "signedIntentsId", "transactionId") SELECT "id", "signedIntentsId", "transactionId" FROM "Intent";
DROP TABLE "Intent";
ALTER TABLE "new_Intent" RENAME TO "Intent";
CREATE TABLE "new_Permission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "delegate" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL,
    CONSTRAINT "Permission_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Permission" ("authority", "delegate", "id", "salt") SELECT "authority", "delegate", "id", "salt" FROM "Permission";
DROP TABLE "Permission";
ALTER TABLE "new_Permission" RENAME TO "Permission";
CREATE TABLE "new_SignedIntents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "signature" TEXT NOT NULL,
    "addressId" TEXT,
    CONSTRAINT "SignedIntents_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_SignedIntents" ("addressId", "id", "signature") SELECT "addressId", "id", "signature" FROM "SignedIntents";
DROP TABLE "SignedIntents";
ALTER TABLE "new_SignedIntents" RENAME TO "SignedIntents";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
