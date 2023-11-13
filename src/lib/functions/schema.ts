import { EIP712DomainSchema } from "@nftchance/plug-types/zod";

import { z } from "zod";

export const getLivePairSchema = <T extends z.ZodTypeAny>(arg: T) =>
  z.object({
    domain: EIP712DomainSchema,
    message: arg,
  });
