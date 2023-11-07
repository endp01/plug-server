import { p } from '@/prisma'

export async function upsertAddress(id: `0x${string}`) {
	// ? Do we need an isAddress check or something here? Is the regex check enough?

	return await p.address.upsert({
		where: {
			id
		},
		create: {
			id
		},
		update: {}
	})
}
