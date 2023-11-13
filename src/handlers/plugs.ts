import { EIP712DomainSchema, PlugsSchema } from "@nftchance/plug-types/zod";

import { z } from "zod";

import { TRPCError } from "@trpc/server";

import { upsertLivePin } from "../handlers/pin";
import { f } from "../framework";
import { p } from "../prisma";

export async function upsertLivePlugs<
  P extends {
    domain: z.infer<typeof EIP712DomainSchema>;
    plugs: z.infer<typeof PlugsSchema>;
    signature: `0x${string}`;
    commit?: boolean;
  },
>({ domain, plugs, signature, commit = true }: P) {
  const intent = f.build("Plugs", plugs, domain);

  if (!intent)
    throw new TRPCError({
      code: "BAD_REQUEST",
    });

  const hash = intent.hash({ domain, message: plugs });
  const signer = await intent.address({
    domain,
    signature: signature,
  });

  const query = {
    where: {
      plugsId_signature: {
        plugsId: hash,
        signature,
      },
    },
    create: {
      address: {
        connectOrCreate: {
          where: {
            id: signer,
          },
          create: {
            id: signer,
          },
        },
      },
      plugs: {
        connectOrCreate: {
          where: {
            id: hash,
          },
          create: {
            id: hash,
            domain: {
              connectOrCreate: {
                where: {
                  verifyingContract_name_version_chainId: domain,
                },
                create: domain,
              },
            },
            plugs: {
              create: await Promise.all(
                plugs.plugs.map(async (intent) => {
                  // * Calculate the type hash of the intent (even though its not signed).
                  const intentPlug = f.build("Plug", intent, domain);

                  if (!intent)
                    throw new TRPCError({
                      code: "BAD_REQUEST",
                    });

                  const intentHash = intentPlug.hash({
                    domain,
                  });

                  return {
                    plug: {
                      connectOrCreate: {
                        where: {
                          id: intentHash,
                        },
                        create: {
                          id: intentHash,
                          current: {
                            connectOrCreate: {
                              where: {
                                ground_voltage_data: intent.current,
                              },
                              create: intent.current,
                            },
                          },
                          pins: {
                            create: await Promise.all(
                              intent.pins.map(async (pin) => {
                                const { query } = await upsertLivePin({
                                  domain,
                                  pin: pin.pin,
                                  signature: pin.signature,
                                  commit: false,
                                });

                                return {
                                  livePin: {
                                    connectOrCreate: query,
                                  },
                                };
                              })
                            ),
                          },
                        },
                      },
                    },
                  };
                })
              ),
            },
            breaker: {
              connectOrCreate: {
                where: {
                  nonce_queue: plugs.breaker,
                },
                create: plugs.breaker,
              },
            },
          },
        },
      },
      signature: signature,
    },
    update: {},
  };

  if (commit) {
    const livePlugs = await p.livePlugs.upsert(query);

    return { signer, query, livePlugs };
  }

  return { signer, query };
}
