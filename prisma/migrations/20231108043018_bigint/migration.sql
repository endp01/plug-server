/*
  Warnings:

  - You are about to alter the column `transactionGasLimit` on the `Intent` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.
  - The primary key for the `SignedPermissionOnIntent` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - The primary key for the `Transaction` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to alter the column `gasLimit` on the `Transaction` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Intent" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "transactionTo" TEXT NOT NULL,
    "transactionGasLimit" BIGINT NOT NULL,
    "transactionData" TEXT NOT NULL,
    CONSTRAINT "Intent_transactionTo_transactionGasLimit_transactionData_fkey" FOREIGN KEY ("transactionTo", "transactionGasLimit", "transactionData") REFERENCES "Transaction" ("to", "gasLimit", "data") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Intent" ("id", "transactionData", "transactionGasLimit", "transactionTo") SELECT "id", "transactionData", "transactionGasLimit", "transactionTo" FROM "Intent";
DROP TABLE "Intent";
ALTER TABLE "new_Intent" RENAME TO "Intent";
CREATE TABLE "new_SignedPermissionOnIntent" (
    "signedPermissionPermissionId" TEXT NOT NULL,
    "signedPermissionSignature" TEXT NOT NULL,
    "intentId" TEXT NOT NULL,

    PRIMARY KEY ("signedPermissionPermissionId", "signedPermissionSignature"),
    CONSTRAINT "SignedPermissionOnIntent_signedPermissionPermissionId_signedPermissionSignature_fkey" FOREIGN KEY ("signedPermissionPermissionId", "signedPermissionSignature") REFERENCES "SignedPermission" ("permissionId", "signature") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedPermissionOnIntent_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Intent" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_SignedPermissionOnIntent" ("intentId", "signedPermissionPermissionId", "signedPermissionSignature") SELECT "intentId", "signedPermissionPermissionId", "signedPermissionSignature" FROM "SignedPermissionOnIntent";
DROP TABLE "SignedPermissionOnIntent";
ALTER TABLE "new_SignedPermissionOnIntent" RENAME TO "SignedPermissionOnIntent";
CREATE TABLE "new_Transaction" (
    "to" TEXT NOT NULL,
    "gasLimit" BIGINT NOT NULL,
    "data" TEXT NOT NULL,

    PRIMARY KEY ("to", "gasLimit", "data")
);
INSERT INTO "new_Transaction" ("data", "gasLimit", "to") SELECT "data", "gasLimit", "to" FROM "Transaction";
DROP TABLE "Transaction";
ALTER TABLE "new_Transaction" RENAME TO "Transaction";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
