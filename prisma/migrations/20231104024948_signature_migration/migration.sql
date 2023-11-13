/*
  Warnings:

  - You are about to drop the column `domainId` on the `LivePin` table. All the data in the column will be lost.
  - You are about to drop the column `domainId` on the `LivePlugs` table. All the data in the column will be lost.
  - Added the required column `domainId` to the `Pin` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_LivePin" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "pinId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "intentId" TEXT,
    "addressId" TEXT,
    CONSTRAINT "LivePin_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "LivePin_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Plug" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "LivePin_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_LivePin" ("addressId", "id", "intentId", "pinId", "signature") SELECT "addressId", "id", "intentId", "pinId", "signature" FROM "LivePin";
DROP TABLE "LivePin";
ALTER TABLE "new_LivePin" RENAME TO "LivePin";
CREATE TABLE "new_Plug" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT,
    "transactionId" TEXT NOT NULL,
    "signedPlugsId" TEXT,
    CONSTRAINT "Plug_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "Plug_signedPlugsId_fkey" FOREIGN KEY ("signedPlugsId") REFERENCES "LivePlugs" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "Plug_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "Transaction" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Plug" ("id", "signedPlugsId", "transactionId") SELECT "id", "signedPlugsId", "transactionId" FROM "Plug";
DROP TABLE "Plug";
ALTER TABLE "new_Plug" RENAME TO "Plug";
CREATE TABLE "new_Pin" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "delegate" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL,
    CONSTRAINT "Pin_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Pin" ("authority", "delegate", "id", "salt") SELECT "authority", "delegate", "id", "salt" FROM "Pin";
DROP TABLE "Pin";
ALTER TABLE "new_Pin" RENAME TO "Pin";
CREATE TABLE "new_LivePlugs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "signature" TEXT NOT NULL,
    "addressId" TEXT,
    CONSTRAINT "LivePlugs_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_LivePlugs" ("addressId", "id", "signature") SELECT "addressId", "id", "signature" FROM "LivePlugs";
DROP TABLE "LivePlugs";
ALTER TABLE "new_LivePlugs" RENAME TO "LivePlugs";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
