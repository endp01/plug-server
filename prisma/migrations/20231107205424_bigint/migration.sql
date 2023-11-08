/*
  Warnings:

  - You are about to alter the column `replayProtectionNonce` on the `Intents` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.
  - You are about to alter the column `replayProtectionQueue` on the `Intents` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.
  - The primary key for the `ReplayProtection` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to alter the column `nonce` on the `ReplayProtection` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.
  - You are about to alter the column `queue` on the `ReplayProtection` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Intents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainVerifyingContract" TEXT NOT NULL,
    "domainName" TEXT NOT NULL,
    "domainVersion" TEXT NOT NULL,
    "domainChainId" INTEGER NOT NULL,
    "replayProtectionNonce" BIGINT NOT NULL,
    "replayProtectionQueue" BIGINT NOT NULL,
    CONSTRAINT "Intents_domainVerifyingContract_domainName_domainVersion_domainChainId_fkey" FOREIGN KEY ("domainVerifyingContract", "domainName", "domainVersion", "domainChainId") REFERENCES "Domain" ("verifyingContract", "name", "version", "chainId") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Intents_replayProtectionNonce_replayProtectionQueue_fkey" FOREIGN KEY ("replayProtectionNonce", "replayProtectionQueue") REFERENCES "ReplayProtection" ("nonce", "queue") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Intents" ("domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "replayProtectionNonce", "replayProtectionQueue") SELECT "domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "replayProtectionNonce", "replayProtectionQueue" FROM "Intents";
DROP TABLE "Intents";
ALTER TABLE "new_Intents" RENAME TO "Intents";
CREATE TABLE "new_ReplayProtection" (
    "nonce" BIGINT NOT NULL,
    "queue" BIGINT NOT NULL,

    PRIMARY KEY ("nonce", "queue")
);
INSERT INTO "new_ReplayProtection" ("nonce", "queue") SELECT "nonce", "queue" FROM "ReplayProtection";
DROP TABLE "ReplayProtection";
ALTER TABLE "new_ReplayProtection" RENAME TO "ReplayProtection";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
