/*
  Warnings:

  - You are about to drop the `Transaction` table. If the table is not empty, all the data it contains will be lost.
  - The primary key for the `LivePinOnPlug` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `intentId` on the `LivePinOnPlug` table. All the data in the column will be lost.
  - You are about to drop the column `signedPinPinId` on the `LivePinOnPlug` table. All the data in the column will be lost.
  - You are about to drop the column `signedPinSignature` on the `LivePinOnPlug` table. All the data in the column will be lost.
  - You are about to drop the column `authority` on the `Pin` table. All the data in the column will be lost.
  - You are about to drop the column `delegate` on the `Pin` table. All the data in the column will be lost.
  - The primary key for the `Fuse` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `enforcer` on the `Fuse` table. All the data in the column will be lost.
  - You are about to drop the column `terms` on the `Fuse` table. All the data in the column will be lost.
  - The primary key for the `PlugOnPlugs` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `intentId` on the `PlugOnPlugs` table. All the data in the column will be lost.
  - The primary key for the `FusesOnPin` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `fuseEnforcer` on the `FusesOnPin` table. All the data in the column will be lost.
  - You are about to drop the column `fuseTerms` on the `FusesOnPin` table. All the data in the column will be lost.
  - You are about to drop the column `transactionData` on the `Plug` table. All the data in the column will be lost.
  - You are about to drop the column `transactionTo` on the `Plug` table. All the data in the column will be lost.
  - You are about to drop the column `transactionvoltage` on the `Plug` table. All the data in the column will be lost.
  - Added the required column `livePinId` to the `LivePinOnPlug` table without a default value. This is not possible if the table is not empty.
  - Added the required column `livePinSignature` to the `LivePinOnPlug` table without a default value. This is not possible if the table is not empty.
  - Added the required column `plugId` to the `LivePinOnPlug` table without a default value. This is not possible if the table is not empty.
  - Added the required column `live` to the `Pin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `neutral` to the `Pin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `live` to the `Fuse` table without a default value. This is not possible if the table is not empty.
  - Added the required column `neutral` to the `Fuse` table without a default value. This is not possible if the table is not empty.
  - Added the required column `plugId` to the `PlugOnPlugs` table without a default value. This is not possible if the table is not empty.
  - Added the required column `fuseLive` to the `FusesOnPin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `fuseNeutral` to the `FusesOnPin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `currentData` to the `Plug` table without a default value. This is not possible if the table is not empty.
  - Added the required column `currentGround` to the `Plug` table without a default value. This is not possible if the table is not empty.
  - Added the required column `currentVoltage` to the `Plug` table without a default value. This is not possible if the table is not empty.

*/
-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Transaction";
PRAGMA foreign_keys=on;

-- CreateTable
CREATE TABLE "Current" (
    "ground" TEXT NOT NULL,
    "voltage" BIGINT NOT NULL,
    "data" TEXT NOT NULL,

    PRIMARY KEY ("ground", "voltage", "data")
);

-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_LivePinOnPlug" (
    "livePinId" TEXT NOT NULL,
    "livePinSignature" TEXT NOT NULL,
    "plugId" TEXT NOT NULL,

    PRIMARY KEY ("livePinId", "livePinSignature", "plugId"),
    CONSTRAINT "LivePinOnPlug_livePinId_livePinSignature_fkey" FOREIGN KEY ("livePinId", "livePinSignature") REFERENCES "LivePin" ("pinId", "signature") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePinOnPlug_plugId_fkey" FOREIGN KEY ("plugId") REFERENCES "Plug" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
DROP TABLE "LivePinOnPlug";
ALTER TABLE "new_LivePinOnPlug" RENAME TO "LivePinOnPlug";
CREATE TABLE "new_Pin" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainVerifyingContract" TEXT NOT NULL,
    "domainName" TEXT NOT NULL,
    "domainVersion" TEXT NOT NULL,
    "domainChainId" INTEGER NOT NULL,
    "neutral" TEXT NOT NULL,
    "live" TEXT NOT NULL,
    "salt" TEXT NOT NULL,
    CONSTRAINT "Pin_domainVerifyingContract_domainName_domainVersion_domainChainId_fkey" FOREIGN KEY ("domainVerifyingContract", "domainName", "domainVersion", "domainChainId") REFERENCES "Domain" ("verifyingContract", "name", "version", "chainId") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Pin" ("domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "salt") SELECT "domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "salt" FROM "Pin";
DROP TABLE "Pin";
ALTER TABLE "new_Pin" RENAME TO "Pin";
CREATE TABLE "new_Fuse" (
    "neutral" TEXT NOT NULL,
    "live" TEXT NOT NULL,

    PRIMARY KEY ("neutral", "live")
);
DROP TABLE "Fuse";
ALTER TABLE "new_Fuse" RENAME TO "Fuse";
CREATE TABLE "new_PlugOnPlugs" (
    "plugId" TEXT NOT NULL,
    "plugsId" TEXT NOT NULL,

    PRIMARY KEY ("plugId", "plugsId"),
    CONSTRAINT "PlugOnPlugs_plugId_fkey" FOREIGN KEY ("plugId") REFERENCES "Plug" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "PlugOnPlugs_plugsId_fkey" FOREIGN KEY ("plugsId") REFERENCES "Plugs" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_PlugOnPlugs" ("plugsId") SELECT "plugsId" FROM "PlugOnPlugs";
DROP TABLE "PlugOnPlugs";
ALTER TABLE "new_PlugOnPlugs" RENAME TO "PlugOnPlugs";
CREATE TABLE "new_FusesOnPin" (
    "pinId" TEXT NOT NULL,
    "fuseNeutral" TEXT NOT NULL,
    "fuseLive" TEXT NOT NULL,

    PRIMARY KEY ("pinId", "fuseNeutral", "fuseLive"),
    CONSTRAINT "FusesOnPin_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "FusesOnPin_fuseNeutral_fuseLive_fkey" FOREIGN KEY ("fuseNeutral", "fuseLive") REFERENCES "Fuse" ("neutral", "live") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_FusesOnPin" ("pinId") SELECT "pinId" FROM "FusesOnPin";
DROP TABLE "FusesOnPin";
ALTER TABLE "new_FusesOnPin" RENAME TO "FusesOnPin";
CREATE TABLE "new_Plug" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "currentGround" TEXT NOT NULL,
    "currentVoltage" BIGINT NOT NULL,
    "currentData" TEXT NOT NULL,
    CONSTRAINT "Plug_currentGround_currentVoltage_currentData_fkey" FOREIGN KEY ("currentGround", "currentVoltage", "currentData") REFERENCES "Current" ("ground", "voltage", "data") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Plug" ("id") SELECT "id" FROM "Plug";
DROP TABLE "Plug";
ALTER TABLE "new_Plug" RENAME TO "Plug";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
