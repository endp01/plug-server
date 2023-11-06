-- CreateTable
CREATE TABLE "EIP712Domain" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "verifyingContract" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "chainId" INTEGER NOT NULL
);

-- CreateTable
CREATE TABLE "Caveat" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "enforcer" TEXT NOT NULL,
    "terms" TEXT NOT NULL,
    "permissionId" TEXT,
    CONSTRAINT "Caveat_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Permission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "delegate" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "SignedPermission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "permissionId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    "intentId" TEXT,
    CONSTRAINT "SignedPermission_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedPermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedPermission_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Intent" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Transaction" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "to" TEXT NOT NULL,
    "gasLimit" INTEGER NOT NULL,
    "data" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "Intent" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "transactionId" TEXT NOT NULL,
    "signedIntentsId" TEXT,
    CONSTRAINT "Intent_transactionId_fkey" FOREIGN KEY ("transactionId") REFERENCES "Transaction" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Intent_signedIntentsId_fkey" FOREIGN KEY ("signedIntentsId") REFERENCES "SignedIntents" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "ReplayProtection" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "nonce" INTEGER NOT NULL,
    "queue" INTEGER NOT NULL
);

-- CreateTable
CREATE TABLE "SignedIntents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "domainId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    CONSTRAINT "SignedIntents_domainId_fkey" FOREIGN KEY ("domainId") REFERENCES "EIP712Domain" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
