/*
  Warnings:

  - You are about to drop the `Caveat` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `CaveatsOnPermission` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `domainChainId` to the `Permission` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainName` to the `Permission` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainVerifyingContract` to the `Permission` table without a default value. This is not possible if the table is not empty.
  - Added the required column `domainVersion` to the `Permission` table without a default value. This is not possible if the table is not empty.

*/
-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Caveat";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "CaveatsOnPermission";
PRAGMA foreign_keys=on;

-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Permission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainVerifyingContract" TEXT NOT NULL,
    "domainName" TEXT NOT NULL,
    "domainVersion" TEXT NOT NULL,
    "domainChainId" INTEGER NOT NULL,
    "delegator" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL,
    CONSTRAINT "Permission_domainVerifyingContract_domainName_domainVersion_domainChainId_fkey" FOREIGN KEY ("domainVerifyingContract", "domainName", "domainVersion", "domainChainId") REFERENCES "Domain" ("verifyingContract", "name", "version", "chainId") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Permission" ("authority", "delegator", "id", "salt") SELECT "authority", "delegator", "id", "salt" FROM "Permission";
DROP TABLE "Permission";
ALTER TABLE "new_Permission" RENAME TO "Permission";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
