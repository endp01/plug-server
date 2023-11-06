import { SignedPermissionSchema } from '@nftchance/emporium-types/zod'

import { EventEmitter } from 'stream'
import { z } from 'zod'

import type { SignedPermission } from '@prisma/client'

import { emit, onEmit } from '../lib/functions/emit'
import { getSignedPairSchema } from '../lib/functions/schema'
import { p } from '../prisma'
import {
	upsertPermission,
	upsertSignedPermission
} from '../prisma/handlers/permission'
import { t } from '../trpc'

const emitter = new EventEmitter()
const procedure = t.procedure
const schema = getSignedPairSchema(SignedPermissionSchema)

export default t.router({
	create: procedure
		.input(schema)
		.output(v => v as SignedPermission)
		.mutation(async req => {
			const { domain, message } = req.input

			// * Verify the base permission and get the signer.
			const { signer, permission } = await upsertPermission({
				domain,
				permission: message.permission,
				signature: message.signature
			})

			// * Add the signed permission object to the database.
			const { signedPermission } = await upsertSignedPermission({
				signer,
				permission,
				signature: message.signature
			})

			// * Announce the event to the connected clients and return
			//   SignedPermission object.
			return emit(emitter, 'create', signedPermission)
		}),
	get: procedure
		.output(v => v as Array<SignedPermission>)
		.query(async req => {
			return await p.signedPermission.findMany()
		}),
	onCreate: procedure.subscription(() =>
		onEmit<SignedPermission>(emitter, 'create')
	)
})
