/*
  Warnings:

  - You are about to drop the `Address` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Fuse` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `EIP712Domain` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Plug` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Pin` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Breaker` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `LivePlugs` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `LivePin` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Transaction` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Address";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Fuse";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "EIP712Domain";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Plug";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Pin";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Breaker";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "LivePlugs";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "LivePin";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Transaction";
PRAGMA foreign_keys=on;

-- CreateTable
CREATE TABLE "Domain" (
    "verifyingContract" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "chainId" INTEGER NOT NULL,

    PRIMARY KEY ("verifyingContract", "name", "version", "chainId")
);
