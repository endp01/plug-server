/*
  Warnings:

  - Made the column `addressId` on table `LivePin` required. This step will fail if there are existing NULL values in that column.
  - Made the column `addressId` on table `LivePlugs` required. This step will fail if there are existing NULL values in that column.

*/
-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_LivePin" (
    "pinId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT NOT NULL,

    PRIMARY KEY ("pinId", "signature"),
    CONSTRAINT "LivePin_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePin_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_LivePin" ("addressId", "pinId", "signature") SELECT "addressId", "pinId", "signature" FROM "LivePin";
DROP TABLE "LivePin";
ALTER TABLE "new_LivePin" RENAME TO "LivePin";
CREATE TABLE "new_LivePlugs" (
    "plugsId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT NOT NULL,

    PRIMARY KEY ("plugsId", "signature"),
    CONSTRAINT "LivePlugs_plugsId_fkey" FOREIGN KEY ("plugsId") REFERENCES "Plugs" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePlugs_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_LivePlugs" ("addressId", "plugsId", "signature") SELECT "addressId", "plugsId", "signature" FROM "LivePlugs";
DROP TABLE "LivePlugs";
ALTER TABLE "new_LivePlugs" RENAME TO "LivePlugs";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
