-- CreateTable
CREATE TABLE "Address" (
    "id" TEXT NOT NULL PRIMARY KEY
);

-- RedefineTables
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_LivePin" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "pinId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "intentId" TEXT,
    "addressId" TEXT,
    CONSTRAINT "LivePin_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePin_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePin_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Plug" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "LivePin_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_LivePin" ("domainId", "id", "intentId", "pinId", "signature") SELECT "domainId", "id", "intentId", "pinId", "signature" FROM "LivePin";
DROP TABLE "LivePin";
ALTER TABLE "new_LivePin" RENAME TO "LivePin";
CREATE TABLE "new_LivePlugs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "addressId" TEXT,
    CONSTRAINT "LivePlugs_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePlugs_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO "new_LivePlugs" ("domainId", "id", "signature") SELECT "domainId", "id", "signature" FROM "LivePlugs";
DROP TABLE "LivePlugs";
ALTER TABLE "new_LivePlugs" RENAME TO "LivePlugs";
PRAGMA foreign_key_check;
PRAGMA foreign_keys=ON;
