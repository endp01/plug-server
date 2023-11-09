import { p } from '@/prisma'

export async function upsertAddress<
	P extends {
		address: `0x${string}`
		commit?: boolean
	}
>({ address, commit = true }: P) {
	const query = {
		where: {
			id: address
		},
		create: {
			id: address
		},
		update: {}
	}

	if (commit) {
		const signer = await p.address.upsert(query)

		return { query, signer }
	}

	return { query }
}
