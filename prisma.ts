import { PrismaClient } from '@prisma/client'

const prismaClientSingleton = () => {
	return new PrismaClient()
}

type PrismaClientSingleton = ReturnType<typeof prismaClientSingleton>

const globalForPrisma = globalThis as unknown as {
	p?: PrismaClientSingleton
}

export const p = globalForPrisma.p || prismaClientSingleton()
export default p

if (process.env.NODE_ENV === 'development') globalForPrisma.p = p
