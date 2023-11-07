import {
    EIP712DomainSchema,
    IntentsSchema
} from '@nftchance/emporium-types/zod'

import { z } from 'zod'

import { TRPCError } from '@trpc/server'

import { f } from '@/framework'
import { p } from '@/prisma'

export async function upsertSignedIntents<
    P extends {
        domain: z.infer<typeof EIP712DomainSchema>
        intents: z.infer<typeof IntentsSchema>
        signature: `0x${string}`
    }
>({ domain, intents, signature }: P) {
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

    const signedIntents = await p.signedIntents.upsert({
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
                                    verifyingContract_name_version_chainId: {
                                        verifyingContract:
                                            domain.verifyingContract,
                                        name: domain.name,
                                        version: domain.version,
                                        chainId: domain.chainId
                                    }
                                },

                                create: domain
                            }
                        },
                        replayProtection: {
                            connectOrCreate: {
                                where: {
                                    nonce_queue: {
                                        nonce: 0,
                                        queue: 0
                                    }
                                },
                                create: {
                                    nonce: 0,
                                    queue: 0
                                }
                            }
                        }
                    }
                }
            },
            signature: signature
        },
        update: {}
    })

    return { signer, signedIntents }
}
