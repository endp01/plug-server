/*
  Warnings:

  - You are about to drop the column `delegator` on the `Permission` table. All the data in the column will be lost.
  - The primary key for the `SignedIntents` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `SignedIntents` table. All the data in the column will be lost.
  - Added the required column `delegate` to the `Permission` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainChainId` to the `Intents` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainName` to the `Intents` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainVerifyingContract` to the `Intents` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainVersion` to the `Intents` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Permission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainVerifyingContract" TEXT NOT NULL,
    "domainName" TEXT NOT NULL,
    "domainVersion" TEXT NOT NULL,
    "domainChainId" INTEGER NOT NULL,
    "delegate" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL,
    CONSTRAINT "Permission_domainVerifyingContract_domainName_domainVersion_domainChainId_fkey" FOREIGN KEY ("domainVerifyingContract", "domainName", "domainVersion", "domainChainId") REFERENCES "Domain" ("verifyingContract", "name", "version", "chainId") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Permission" ("authority", "domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "salt") SELECT "authority", "domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "salt" FROM "Permission";
DROP TABLE "Permission";
ALTER TABLE "new_Permission" RENAME TO "Permission";
CREATE TABLE "new_SignedPermission" (
    "permissionId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT,

    PRIMARY KEY ("permissionId", "signature"),
    CONSTRAINT "SignedPermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedPermission_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_SignedPermission" ("permissionId", "signature") SELECT "permissionId", "signature" FROM "SignedPermission";
DROP TABLE "SignedPermission";
ALTER TABLE "new_SignedPermission" RENAME TO "SignedPermission";
CREATE TABLE "new_SignedIntents" (
    "intentsId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT,

    PRIMARY KEY ("intentsId", "signature"),
    CONSTRAINT "SignedIntents_intentsId_fkey" FOREIGN KEY ("intentsId") REFERENCES "Intents" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedIntents_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_SignedIntents" ("intentsId", "signature") SELECT "intentsId", "signature" FROM "SignedIntents";
DROP TABLE "SignedIntents";
ALTER TABLE "new_SignedIntents" RENAME TO "SignedIntents";
CREATE TABLE "new_Intents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainVerifyingContract" TEXT NOT NULL,
    "domainName" TEXT NOT NULL,
    "domainVersion" TEXT NOT NULL,
    "domainChainId" INTEGER NOT NULL,
    "replayProtectionNonce" INTEGER NOT NULL,
    "replayProtectionQueue" INTEGER NOT NULL,
    CONSTRAINT "Intents_domainVerifyingContract_domainName_domainVersion_domainChainId_fkey" FOREIGN KEY ("domainVerifyingContract", "domainName", "domainVersion", "domainChainId") REFERENCES "Domain" ("verifyingContract", "name", "version", "chainId") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Intents_replayProtectionNonce_replayProtectionQueue_fkey" FOREIGN KEY ("replayProtectionNonce", "replayProtectionQueue") REFERENCES "ReplayProtection" ("nonce", "queue") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Intents" ("id", "replayProtectionNonce", "replayProtectionQueue") SELECT "id", "replayProtectionNonce", "replayProtectionQueue" FROM "Intents";
DROP TABLE "Intents";
ALTER TABLE "new_Intents" RENAME TO "Intents";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
