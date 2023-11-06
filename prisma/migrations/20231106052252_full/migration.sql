-- CreateTable
CREATE TABLE "Caveat" (
    "enforcer" TEXT NOT NULL,
    "terms" TEXT NOT NULL,

    PRIMARY KEY ("enforcer", "terms")
);

-- CreateTable
CREATE TABLE "CaveatsOnPermission" (
    "permissionId" TEXT NOT NULL,
    "caveatEnforcer" TEXT NOT NULL,
    "caveatTerms" TEXT NOT NULL,

    PRIMARY KEY ("permissionId", "caveatEnforcer", "caveatTerms"),
    CONSTRAINT "CaveatsOnPermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "CaveatsOnPermission_caveatEnforcer_caveatTerms_fkey" FOREIGN KEY ("caveatEnforcer", "caveatTerms") REFERENCES "Caveat" ("enforcer", "terms") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "SignedPermission" (
    "permissionId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,

    PRIMARY KEY ("permissionId", "signature"),
    CONSTRAINT "SignedPermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Transaction" (
    "to" TEXT NOT NULL,
    "gasLimit" INTEGER NOT NULL,
    "data" TEXT NOT NULL,

    PRIMARY KEY ("to", "gasLimit", "data")
);

-- CreateTable
CREATE TABLE "SignedPermissionOnIntent" (
    "signedPermissionPermissionId" TEXT NOT NULL,
    "signedPermissionSignature" TEXT NOT NULL,
    "intentId" TEXT NOT NULL,

    PRIMARY KEY ("signedPermissionPermissionId", "signedPermissionSignature", "intentId"),
    CONSTRAINT "SignedPermissionOnIntent_signedPermissionPermissionId_signedPermissionSignature_fkey" FOREIGN KEY ("signedPermissionPermissionId", "signedPermissionSignature") REFERENCES "SignedPermission" ("permissionId", "signature") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "SignedPermissionOnIntent_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Intent" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Intent" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "transactionTo" TEXT NOT NULL,
    "transactionGasLimit" INTEGER NOT NULL,
    "transactionData" TEXT NOT NULL,
    CONSTRAINT "Intent_transactionTo_transactionGasLimit_transactionData_fkey" FOREIGN KEY ("transactionTo", "transactionGasLimit", "transactionData") REFERENCES "Transaction" ("to", "gasLimit", "data") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "ReplayProtection" (
    "nonce" INTEGER NOT NULL,
    "queue" INTEGER NOT NULL,

    PRIMARY KEY ("nonce", "queue")
);

-- CreateTable
CREATE TABLE "IntentOnIntents" (
    "intentId" TEXT NOT NULL,
    "intentsId" TEXT NOT NULL,

    PRIMARY KEY ("intentId", "intentsId"),
    CONSTRAINT "IntentOnIntents_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Intent" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "IntentOnIntents_intentsId_fkey" FOREIGN KEY ("intentsId") REFERENCES "Intents" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Intents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "replayProtectionNonce" INTEGER NOT NULL,
    "replayProtectionQueue" INTEGER NOT NULL,
    CONSTRAINT "Intents_replayProtectionNonce_replayProtectionQueue_fkey" FOREIGN KEY ("replayProtectionNonce", "replayProtectionQueue") REFERENCES "ReplayProtection" ("nonce", "queue") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "SignedIntents" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "intentsId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    CONSTRAINT "SignedIntents_intentsId_fkey" FOREIGN KEY ("intentsId") REFERENCES "Intents" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
