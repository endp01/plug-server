import { EIP712DomainSchema, PinSchema } from "@nftchance/plug-types/zod";

import { z } from "zod";

import { TRPCError } from "@trpc/server";

import { f } from "../framework";
import { p } from "../prisma";

export async function upsertLivePin<
  P extends {
    domain: z.infer<typeof EIP712DomainSchema>;
    pin: z.infer<typeof PinSchema>;
    signature: `0x${string}`;
    commit?: boolean;
  },
>({ domain, pin, signature, commit = true }: P) {
  const intent = f.build("Pin", pin, domain);

  if (!intent)
    throw new TRPCError({
      code: "BAD_REQUEST",
    });

  const hash = intent.hash({ domain, message: pin });
  const signer = await intent.address({
    domain,
    signature: signature,
  });

  const query = {
    where: {
      pinId_signature: {
        pinId: hash,
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
      pin: {
        connectOrCreate: {
          where: {
            id: hash,
          },
          create: {
            id: hash,
            domain: {
              connectOrCreate: {
                where: {
                  verifyingContract_name_version_chainId: {
                    verifyingContract: domain.verifyingContract,
                    name: domain.name,
                    version: domain.version,
                    chainId: domain.chainId,
                  },
                },
                create: domain,
              },
            },
            neutral: pin.neutral,
            live: pin.live,
            fuses: {
              connectOrCreate: pin.fuses.map((fuse) => ({
                where: {
                  pinId_fuseNeutral_fuseLive: {
                    pinId: hash,
                    fuseNeutral: fuse.neutral,
                    fuseLive: fuse.live,
                  },
                },
                create: {
                  pinId: hash,
                  fuseNeutral: fuse.neutral,
                  fuseLive: fuse.live,
                },
              })),
            },
            salt: pin.salt,
          },
        },
      },
      signature: signature,
    },
    update: {},
  };

  if (commit) {
    const livePin = await p.livePin.upsert(query);

    return { query, signer, livePin };
  }

  return { query, signer };
}
