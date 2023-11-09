import { SignedPermissionSchema } from '@nftchance/emporium-types/zod'

import { EventEmitter } from 'stream'

import type { SignedPermission } from '@prisma/client'
import { TRPCError } from '@trpc/server'
import { observable } from '@trpc/server/observable'

import { getSignedPairSchema } from '@/lib/functions/schema'
import { upsertSignedPermission } from '@/handlers/permission'
import { p } from '@/prisma'
import { t } from '@/trpc'

const emitter = new EventEmitter()
const procedure = t.procedure
const schema = getSignedPairSchema(SignedPermissionSchema)

export default t.router({
	create: procedure.input(schema).mutation(async req => {
		const { domain, message } = req.input

		// * Add the signed permission object to the database.
		try {
			const { signedPermission } = await upsertSignedPermission({
				domain,
				permission: message.permission,
				signature: message.signature
			})

			emitter.emit('create', signedPermission)

			return signedPermission
		} catch {
			throw new TRPCError({
				code: 'BAD_REQUEST',
				message: 'Invalid message/signature body provided.'
			})
		}
	}),
	get: procedure.query(async () => {
		return await p.signedPermission.findMany()
	}),
	onCreate: procedure.subscription(() => {
		return observable<SignedPermission>(emit => {
			emitter.on('create', emit.next)

			return () => {
				emitter.off('create', emit.next)
			}
		})
	})
})
