import { EIP712DomainSchema } from "@nftchance/plug-types/zod";

import { z } from "zod";

export const getSignedPairSchema = <T extends z.ZodTypeAny>(arg: T) =>
  z.object({
    domain: EIP712DomainSchema,
    message: arg,
  });
