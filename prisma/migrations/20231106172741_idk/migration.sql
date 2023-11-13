/*
  Warnings:

  - You are about to drop the column `delegator` on the `Pin` table. All the data in the column will be lost.
  - The primary key for the `LivePlugs` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `id` on the `LivePlugs` table. All the data in the column will be lost.
  - Added the required column `delegate` to the `Pin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainChainId` to the `Plugs` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainName` to the `Plugs` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainVerifyingContract` to the `Plugs` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainVersion` to the `Plugs` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Pin" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainVerifyingContract" TEXT NOT NULL,
    "domainName" TEXT NOT NULL,
    "domainVersion" TEXT NOT NULL,
    "domainChainId" INTEGER NOT NULL,
    "delegate" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL,
    CONSTRAINT "Pin_domainVerifyingContract_domainName_domainVersion_domainChainId_fkey" FOREIGN KEY ("domainVerifyingContract", "domainName", "domainVersion", "domainChainId") REFERENCES "Domain" ("verifyingContract", "name", "version", "chainId") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Pin" ("authority", "domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "salt") SELECT "authority", "domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "salt" FROM "Pin";
DROP TABLE "Pin";
ALTER TABLE "new_Pin" RENAME TO "Pin";
CREATE TABLE "new_LivePin" (
    "pinId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT,

    PRIMARY KEY ("pinId", "signature"),
    CONSTRAINT "LivePin_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePin_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_LivePin" ("pinId", "signature") SELECT "pinId", "signature" FROM "LivePin";
DROP TABLE "LivePin";
ALTER TABLE "new_LivePin" RENAME TO "LivePin";
CREATE TABLE "new_LivePlugs" (
    "plugsId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT,

    PRIMARY KEY ("plugsId", "signature"),
    CONSTRAINT "LivePlugs_plugsId_fkey" FOREIGN KEY ("plugsId") REFERENCES "Plugs" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePlugs_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_LivePlugs" ("plugsId", "signature") SELECT "plugsId", "signature" FROM "LivePlugs";
DROP TABLE "LivePlugs";
ALTER TABLE "new_LivePlugs" RENAME TO "LivePlugs";
CREATE TABLE "new_Plugs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainVerifyingContract" TEXT NOT NULL,
    "domainName" TEXT NOT NULL,
    "domainVersion" TEXT NOT NULL,
    "domainChainId" INTEGER NOT NULL,
    "breakerNonce" INTEGER NOT NULL,
    "breakerQueue" INTEGER NOT NULL,
    CONSTRAINT "Plugs_domainVerifyingContract_domainName_domainVersion_domainChainId_fkey" FOREIGN KEY ("domainVerifyingContract", "domainName", "domainVersion", "domainChainId") REFERENCES "Domain" ("verifyingContract", "name", "version", "chainId") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Plugs_breakerNonce_breakerQueue_fkey" FOREIGN KEY ("breakerNonce", "breakerQueue") REFERENCES "Breaker" ("nonce", "queue") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Plugs" ("id", "breakerNonce", "breakerQueue") SELECT "id", "breakerNonce", "breakerQueue" FROM "Plugs";
DROP TABLE "Plugs";
ALTER TABLE "new_Plugs" RENAME TO "Plugs";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
