/*
  Warnings:

  - You are about to alter the column `transactionvoltage` on the `Plug` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.
  - The primary key for the `LivePinOnPlug` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `Transaction` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to alter the column `voltage` on the `Transaction` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Plug" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "transactionTo" TEXT NOT NULL,
    "transactionvoltage" BIGINT NOT NULL,
    "transactionData" TEXT NOT NULL,
    CONSTRAINT "Plug_transactionTo_transactionvoltage_transactionData_fkey" FOREIGN KEY ("transactionTo", "transactionvoltage", "transactionData") REFERENCES "Transaction" ("to", "voltage", "data") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Plug" ("id", "transactionData", "transactionvoltage", "transactionTo") SELECT "id", "transactionData", "transactionvoltage", "transactionTo" FROM "Plug";
DROP TABLE "Plug";
ALTER TABLE "new_Plug" RENAME TO "Plug";
CREATE TABLE "new_LivePinOnPlug" (
    "signedPinPinId" TEXT NOT NULL,
    "signedPinSignature" TEXT NOT NULL,
    "intentId" TEXT NOT NULL,

    PRIMARY KEY ("signedPinPinId", "signedPinSignature"),
    CONSTRAINT "LivePinOnPlug_signedPinPinId_signedPinSignature_fkey" FOREIGN KEY ("signedPinPinId", "signedPinSignature") REFERENCES "LivePin" ("pinId", "signature") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePinOnPlug_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Plug" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_LivePinOnPlug" ("intentId", "signedPinPinId", "signedPinSignature") SELECT "intentId", "signedPinPinId", "signedPinSignature" FROM "LivePinOnPlug";
DROP TABLE "LivePinOnPlug";
ALTER TABLE "new_LivePinOnPlug" RENAME TO "LivePinOnPlug";
CREATE TABLE "new_Transaction" (
    "to" TEXT NOT NULL,
    "voltage" BIGINT NOT NULL,
    "data" TEXT NOT NULL,

    PRIMARY KEY ("to", "voltage", "data")
);
INSERT INTO "new_Transaction" ("data", "voltage", "to") SELECT "data", "voltage", "to" FROM "Transaction";
DROP TABLE "Transaction";
ALTER TABLE "new_Transaction" RENAME TO "Transaction";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
