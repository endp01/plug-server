-- CreateTable
CREATE TABLE "EIP712Domain" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "verifyingContract" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "chainId" INTEGER NOT NULL
);

-- CreateTable
CREATE TABLE "Fuse" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "enforcer" TEXT NOT NULL,
    "terms" TEXT NOT NULL,
    "pinId" TEXT,
    CONSTRAINT "Fuse_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Pin" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "delegate" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "LivePin" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "pinId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "intentId" TEXT,
    CONSTRAINT "LivePin_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePin_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePin_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Plug" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Transaction" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "to" TEXT NOT NULL,
    "voltage" INTEGER NOT NULL,
    "data" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "Plug" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "transactionId" TEXT NOT NULL,
    "signedPlugsId" TEXT,
    CONSTRAINT "Plug_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "Transaction" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Plug_signedPlugsId_fkey" FOREIGN KEY ("signedPlugsId") REFERENCES "LivePlugs" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Breaker" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "nonce" INTEGER NOT NULL,
    "queue" INTEGER NOT NULL
);

-- CreateTable
CREATE TABLE "LivePlugs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    CONSTRAINT "LivePlugs_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
