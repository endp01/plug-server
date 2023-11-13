/*
  Warnings:

  - You are about to drop the `Fuse` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `FusesOnPin` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `domainChainId` to the `Pin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainName` to the `Pin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainVerifyingContract` to the `Pin` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainVersion` to the `Pin` table without a default value. This is not possible if the table is not empty.

*/
-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Fuse";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "FusesOnPin";
PRAGMA foreign_keys=on;

-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Pin" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainVerifyingContract" TEXT NOT NULL,
    "domainName" TEXT NOT NULL,
    "domainVersion" TEXT NOT NULL,
    "domainChainId" INTEGER NOT NULL,
    "delegator" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL,
    CONSTRAINT "Pin_domainVerifyingContract_domainName_domainVersion_domainChainId_fkey" FOREIGN KEY ("domainVerifyingContract", "domainName", "domainVersion", "domainChainId") REFERENCES "Domain" ("verifyingContract", "name", "version", "chainId") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Pin" ("authority", "delegator", "id", "salt") SELECT "authority", "delegator", "id", "salt" FROM "Pin";
DROP TABLE "Pin";
ALTER TABLE "new_Pin" RENAME TO "Pin";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
