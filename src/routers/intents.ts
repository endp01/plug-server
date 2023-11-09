import { SignedIntentsSchema } from '@nftchance/emporium-types/zod'

import { EventEmitter } from 'stream'

import type { SignedIntents } from '@prisma/client'
import { TRPCError } from '@trpc/server'
import { observable } from '@trpc/server/observable'

import { getSignedPairSchema } from '../lib/functions/schema'
import { upsertSignedIntents } from '../handlers/intents'
import { p } from '../prisma'
import { t } from '../trpc'

const emitter = new EventEmitter()
const procedure = t.procedure
const schema = getSignedPairSchema(SignedIntentsSchema)

export default t.router({
	create: procedure.input(schema).mutation(async req => {
		const { domain, message } = req.input

		try {
			const { signedIntents } = await upsertSignedIntents({
				domain,
				intents: message.intents,
				signature: message.signature
			})

			emitter.emit('create', signedIntents)

			return signedIntents
		} catch {
			throw new TRPCError({
				code: 'BAD_REQUEST',
				message: 'Invalid message/signature body provided.'
			})
		}
	}),
	get: procedure.query(async () => {
		return await p.signedIntents.findMany()
	}),
	onCreate: procedure.subscription(() => {
		return observable<SignedIntents>(emit => {
			emitter.on('create', emit.next)

			return () => {
				emitter.off('create', emit.next)
			}
		})
	})
})
