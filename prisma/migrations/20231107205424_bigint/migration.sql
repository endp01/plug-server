/*
  Warnings:

  - You are about to alter the column `breakerNonce` on the `Plugs` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.
  - You are about to alter the column `breakerQueue` on the `Plugs` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.
  - The primary key for the `Breaker` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to alter the column `nonce` on the `Breaker` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.
  - You are about to alter the column `queue` on the `Breaker` table. The data in that column could be lost. The data in that column will be cast from `Int` to `BigInt`.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Plugs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainVerifyingContract" TEXT NOT NULL,
    "domainName" TEXT NOT NULL,
    "domainVersion" TEXT NOT NULL,
    "domainChainId" INTEGER NOT NULL,
    "breakerNonce" BIGINT NOT NULL,
    "breakerQueue" BIGINT NOT NULL,
    CONSTRAINT "Plugs_domainVerifyingContract_domainName_domainVersion_domainChainId_fkey" FOREIGN KEY ("domainVerifyingContract", "domainName", "domainVersion", "domainChainId") REFERENCES "Domain" ("verifyingContract", "name", "version", "chainId") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Plugs_breakerNonce_breakerQueue_fkey" FOREIGN KEY ("breakerNonce", "breakerQueue") REFERENCES "Breaker" ("nonce", "queue") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Plugs" ("domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "breakerNonce", "breakerQueue") SELECT "domainChainId", "domainName", "domainVerifyingContract", "domainVersion", "id", "breakerNonce", "breakerQueue" FROM "Plugs";
DROP TABLE "Plugs";
ALTER TABLE "new_Plugs" RENAME TO "Plugs";
CREATE TABLE "new_Breaker" (
    "nonce" BIGINT NOT NULL,
    "queue" BIGINT NOT NULL,

    PRIMARY KEY ("nonce", "queue")
);
INSERT INTO "new_Breaker" ("nonce", "queue") SELECT "nonce", "queue" FROM "Breaker";
DROP TABLE "Breaker";
ALTER TABLE "new_Breaker" RENAME TO "Breaker";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
