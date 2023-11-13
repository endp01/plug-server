-- CreateTable
CREATE TABLE "Fuse" (
    "enforcer" TEXT NOT NULL,
    "terms" TEXT NOT NULL,

    PRIMARY KEY ("enforcer", "terms")
);

-- CreateTable
CREATE TABLE "FusesOnPin" (
    "fuseEnforcer" TEXT NOT NULL,
    "fuseTerms" TEXT NOT NULL,
    "pinId" TEXT NOT NULL,

    PRIMARY KEY ("fuseEnforcer", "fuseTerms", "pinId"),
    CONSTRAINT "FusesOnPin_fuseEnforcer_fuseTerms_fkey" FOREIGN KEY ("fuseEnforcer", "fuseTerms") REFERENCES "Fuse" ("enforcer", "terms") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "FusesOnPin_pinId_fkey" FOREIGN KEY ("pinId") REFERENCES "Pin" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Pin" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "delegator" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL
);
