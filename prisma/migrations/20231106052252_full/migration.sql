-- CreateTable
CREATE TABLE "Fuse" (
    "enforcer" TEXT NOT NULL,
    "terms" TEXT NOT NULL,

    PRIMARY KEY ("enforcer", "terms")
);

-- CreateTable
CREATE TABLE "FusesOnPin" (
    "pinId" TEXT NOT NULL,
    "fuseEnforcer" TEXT NOT NULL,
    "fuseTerms" TEXT NOT NULL,

    PRIMARY KEY ("pinId", "fuseEnforcer", "fuseTerms"),
    CONSTRAINT "FusesOnPin_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "FusesOnPin_fuseEnforcer_fuseTerms_fkey" FOREIGN KEY ("fuseEnforcer", "fuseTerms") REFERENCES "Fuse" ("enforcer", "terms") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "LivePin" (
    "pinId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,

    PRIMARY KEY ("pinId", "signature"),
    CONSTRAINT "LivePin_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Transaction" (
    "to" TEXT NOT NULL,
    "voltage" INTEGER NOT NULL,
    "data" TEXT NOT NULL,

    PRIMARY KEY ("to", "voltage", "data")
);

-- CreateTable
CREATE TABLE "LivePinOnPlug" (
    "signedPinPinId" TEXT NOT NULL,
    "signedPinSignature" TEXT NOT NULL,
    "intentId" TEXT NOT NULL,

    PRIMARY KEY ("signedPinPinId", "signedPinSignature", "intentId"),
    CONSTRAINT "LivePinOnPlug_signedPinPinId_signedPinSignature_fkey" FOREIGN KEY ("signedPinPinId", "signedPinSignature") REFERENCES "LivePin" ("pinId", "signature") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "LivePinOnPlug_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Plug" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Plug" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "transactionTo" TEXT NOT NULL,
    "transactionvoltage" INTEGER NOT NULL,
    "transactionData" TEXT NOT NULL,
    CONSTRAINT "Plug_transactionTo_transactionvoltage_transactionData_fkey" FOREIGN KEY ("transactionTo", "transactionvoltage", "transactionData") REFERENCES "Transaction" ("to", "voltage", "data") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Breaker" (
    "nonce" INTEGER NOT NULL,
    "queue" INTEGER NOT NULL,

    PRIMARY KEY ("nonce", "queue")
);

-- CreateTable
CREATE TABLE "PlugOnPlugs" (
    "intentId" TEXT NOT NULL,
    "plugsId" TEXT NOT NULL,

    PRIMARY KEY ("intentId", "plugsId"),
    CONSTRAINT "PlugOnPlugs_intentId_fkey" FOREIGN KEY ("intentId") REFERENCES "Plug" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "PlugOnPlugs_plugsId_fkey" FOREIGN KEY ("plugsId") REFERENCES "Plugs" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Plugs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "breakerNonce" INTEGER NOT NULL,
    "breakerQueue" INTEGER NOT NULL,
    CONSTRAINT "Plugs_breakerNonce_breakerQueue_fkey" FOREIGN KEY ("breakerNonce", "breakerQueue") REFERENCES "Breaker" ("nonce", "queue") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "LivePlugs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "plugsId" TEXT NOT NULL,
    "signature" TEXT NOT NULL,
    CONSTRAINT "LivePlugs_plugsId_fkey" FOREIGN KEY ("plugsId") REFERENCES "Plugs" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
