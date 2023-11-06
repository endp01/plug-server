import { SignedIntentsSchema } from '@nftchance/emporium-types/zod'

import { EventEmitter } from 'stream'
import { z } from 'zod'

import type { SignedIntents } from '@prisma/client'
import { TRPCError } from '@trpc/server'

import { f } from '../framework'
import { emit, onEmit } from '../lib/functions/emit'
import { getSignedPairSchema } from '../lib/functions/schema'
import { p } from '../prisma'
import { upsertAddress } from '../prisma/handlers/address'
import {
	upsertPermission,
	upsertSignedPermission
} from '../prisma/handlers/permission'
import { t } from '../trpc'

const emitter = new EventEmitter()
const procedure = t.procedure
const schema = getSignedPairSchema(SignedIntentsSchema)

export default t.router({
	create: procedure
		.input(schema)
		.output(v => v as SignedIntents)
		.mutation(async req => {
			let [hash, signer] = Array(2).fill(null)

			const { domain, message } = req.input

			// * Parse the signed message and make sure it is valid.
			const intent = f.build('Intents', message.intents, domain)

			// * Recover the message hash.
			try {
				hash = intent.hash({ domain, message: message.intents })
			} catch (e) {
				throw new TRPCError({
					code: 'BAD_REQUEST',
					message: 'Invalid message provided.'
				})
			}

			try {
				// * Recover the signer address.
				signer = await intent.address({
					domain,
					signature: message.signature
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

			hash

			// * Loop through all of the intents and then loop through all
			//   of the authorities as they are the underlying piece of the authorization.
			// ? Why use a for loop like this? Because we don't want to copy everything
			//   into memory and then loop through it.
			const signedPermissions = []
			for (const { authority } of message.intents.batch) {
				for (const { permission, signature } of authority) {
					// * Verify the base permission and get the signer.
					const { signer, permission: permissionObject } =
						await upsertPermission({
							domain,
							permission: permission,
							signature: signature
						})

					// * Add the signed permission object to the database.
					const { signedPermission } = await upsertSignedPermission({
						signer,
						permission: permissionObject,
						signature: signature
					})

					signedPermissions.push(signedPermission)
				}
			}

			// TODO: Create the Transaction object.
			// TODO: Create the Intent object.
			// TODO: Create the ReplayProtection object.
			// TODO: Create the SignedIntents object.
			// TODO: Add the item to the Address.

			return emit(emitter, 'create', null)
		}),
	get: procedure
		.input(z.string())
		.output(v => v as SignedIntents)
		.query(async req => {
			const signedIntents = await p.signedIntents.findUnique({
				where: {
					id: req.input
				}
			})

			if (signedIntents === null)
				throw new TRPCError({ code: 'NOT_FOUND' })

			return signedIntents
		}),
	onCreate: procedure.subscription(() =>
		onEmit<SignedIntents>(emitter, 'create')
	)
})
