import {
	EIP712DomainSchema,
	IntentsSchema
} from '@nftchance/emporium-types/zod'

import { z } from 'zod'
import { TRPCError } from '@trpc/server'

import { f } from '@/framework'
import { p } from '@/prisma'
import { upsertSignedPermission } from '@/prisma/handlers/permission'

export async function upsertSignedIntents<
	P extends {
		domain: z.infer<typeof EIP712DomainSchema>
		intents: z.infer<typeof IntentsSchema>
		signature: `0x${string}`,
        commit?: boolean
	}
>({ domain, intents, signature, commit=true }: P) {
	const intent = f.build('Intents', intents, domain)

	if (!intent)
		throw new TRPCError({
			code: 'BAD_REQUEST'
		})

	const hash = intent.hash({ domain, message: intents })
	const signer = await intent.address({
		domain,
		signature: signature
	})

    const query = {
		where: {
			intentsId_signature: {
				intentsId: hash,
				signature
			}
		},
		create: {
			address: {
				connectOrCreate: {
					where: {
						id: signer
					},
					create: {
						id: signer
					}
				}
			},
			intents: {
				connectOrCreate: {
					where: {
						id: hash
					},
					create: {
						id: hash,
						domain: {
							connectOrCreate: {
								where: {
									verifyingContract_name_version_chainId:
										domain
								},
								create: domain
							}
						},
						batch: {
							create: await Promise.all(intents.batch.map(async intent => {
								// * Calculate the type hash of the intent (even though its not signed).
								const intentIntent = f.build(
									'Intent',
									intent,
									domain
								)

								if (!intent)
									throw new TRPCError({
										code: 'BAD_REQUEST'
									})

								const intentHash = intentIntent.hash({ domain })

								return {
									intent: {
										connectOrCreate: {
											where: {
												id: intentHash
											},
											create: {
												id: intentHash,
												transaction: {
													connectOrCreate: {
														where: {
															to_gasLimit_data:
																intent.transaction
														},
														create: intent.transaction
													}
												},
												authority: {
                                                    create: await Promise.all(intent.authority.map(async authority => {  
                                                        const { query } = await upsertSignedPermission({
                                                            domain, 
                                                            permission: authority.permission,
                                                            signature: authority.signature,
                                                            commit: false
                                                        })

                                                        return {
															signedPermission: {
																connectOrCreate: query
															}
														}
                                                    }))
												}
											}
										}
									}
								}
							}))
						},
						replayProtection: {
							connectOrCreate: {
								where: {
									nonce_queue: intents.replayProtection
								},
								create: intents.replayProtection
							}
						}
					}
				}
			},
			signature: signature
		},
		update: {}
	}


    if(commit) { 
	    const signedIntents = await p.signedIntents.upsert(query)

	    return { signer, query, signedIntents }
    }

	return { signer, query }
}
