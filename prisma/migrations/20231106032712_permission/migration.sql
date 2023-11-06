-- CreateTable
CREATE TABLE "Caveat" (
    "enforcer" TEXT NOT NULL,
    "terms" TEXT NOT NULL,

    PRIMARY KEY ("enforcer", "terms")
);

-- CreateTable
CREATE TABLE "CaveatsOnPermission" (
    "caveatEnforcer" TEXT NOT NULL,
    "caveatTerms" TEXT NOT NULL,
    "permissionId" TEXT NOT NULL,

    PRIMARY KEY ("caveatEnforcer", "caveatTerms", "permissionId"),
    CONSTRAINT "CaveatsOnPermission_caveatEnforcer_caveatTerms_fkey" FOREIGN KEY ("caveatEnforcer", "caveatTerms") REFERENCES "Caveat" ("enforcer", "terms") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "CaveatsOnPermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Permission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "delegator" TEXT NOT NULL,
    "authority" TEXT NOT NULL,
    "salt" TEXT NOT NULL
);
