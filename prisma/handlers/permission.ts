import {
	EIP712DomainSchema,
	PermissionSchema
} from '@nftchance/emporium-types/zod'

import { z } from 'zod'

import { TRPCError } from '@trpc/server'

import { f } from '../../framework'
import { p } from '../../prisma'
import { upsertAddress } from './address'

export async function upsertPermission<
	P extends {
		domain: z.infer<typeof EIP712DomainSchema>
		permission: z.infer<typeof PermissionSchema>
		signature: `0x${string}`
	}
>({ domain, permission, signature }: P) {
	let hash: `0x${string}` | null = null
	let signer: `0x${string}` | null = null

	// * Parse the signed message and make sure it is valid.
	// TODO: It could still throw here and crash.
	const intent = f.build('Permission', permission, domain)

	// * Recover the message hash.
	try {
		hash = intent.hash({ domain, message: permission })
	} catch (e) {
		throw new TRPCError({
			code: 'BAD_REQUEST',
			message: 'Invalid message provided.'
		})
	}

	try {
		// * Recover the signer address and return it to use above.
		signer = await intent.address({
			domain,
			signature: signature
		})

		// * Create the Address object if it doesn't exist.
		await upsertAddress(signer)
	} catch (e) {
		// TODO: Punish the gossiper for sending bad data through X-API-KEY layer.

		// * Error out if the message was impersonated.
		throw new TRPCError({
			code: 'BAD_REQUEST',
			message: 'Invalid message signature provided.'
		})
	}

	// * Create the permission object (that we know has been signed.)
	const permissionObject = await p.permission.upsert({
		where: {
			id: hash
		},
		create: {
			id: hash,
			domain: {
				create: domain
			},
			delegate: permission.delegate,
			authority: permission.authority,
			// * Create the Caveat objects if they don't exist.
			caveats: {
				connectOrCreate: permission.caveats.map(caveat => {
					if (!hash) throw new Error('hash is null')

					return {
						where: {
							permissionId_caveatEnforcer_caveatTerms: {
								permissionId: hash,
								caveatEnforcer: caveat.enforcer,
								caveatTerms: caveat.terms
							}
						},
						create: {
							permissionId: hash,
							caveatEnforcer: caveat.enforcer,
							caveatTerms: caveat.terms
						}
					}
				})
			},
			salt: permission.salt
		},
		update: {}
	})

	return { signer, permission: permissionObject }
}

export async function upsertSignedPermission<
	P extends {
		signer: `0x${string}`
		permission: Awaited<ReturnType<typeof upsertPermission>>['permission']
		signature: `0x${string}`
	}
>({ signer, permission, signature }: P) {
	// * Create the SignedPermission object if it doesn't exist.
	// ? Have to do it this way because we need to get the ID of the signedPermission.
	// ! It would be wise to use the hash of the SignedPermission but emporium-core
	//   doesn't have a way to do that yet.
	const signedPermission = await p.signedPermission.create({
		data: {
			permission: {
				connect: {
					id: permission.id
				}
			},
			signature: signature
		}
	})

	// * Add the signedPermission to the Address.signedPermissions array.
	// ? If the signedPermission already exists, we don't need to do anything.
	await p.address.update({
		where: {
			id: signer
		},
		data: {
			signedPermissions: {
				connect: {
					id: signedPermission.id
				}
			}
		}
	})

	return { signer, signedPermission }
}
