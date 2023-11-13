import { LivePlugsSchema } from "@nftchance/plug-types/zod";

import { EventEmitter } from "stream";

import type { LivePlugs } from "@prisma/client";
import { TRPCError } from "@trpc/server";
import { observable } from "@trpc/server/observable";

import { getLivePairSchema } from "../lib/functions/schema";
import { upsertLivePlugs } from "../handlers/plugs";
import { p } from "../prisma";
import { t } from "../trpc";

const emitter = new EventEmitter();
const procedure = t.procedure;
const schema = getLivePairSchema(LivePlugsSchema);

export default t.router({
  create: procedure.input(schema).mutation(async (req) => {
    const { domain, message } = req.input;

    try {
      const { livePlugs } = await upsertLivePlugs({
        domain,
        plugs: message.plugs,
        signature: message.signature,
      });

      emitter.emit("create", livePlugs);

      return livePlugs;
    } catch {
      throw new TRPCError({
        code: "BAD_REQUEST",
        message: "Invalid message/signature body provided.",
      });
    }
  }),
  get: procedure.query(async () => {
    return await p.livePlugs.findMany();
  }),
  onCreate: procedure.subscription(() => {
    return observable<LivePlugs>((emit) => {
      emitter.on("create", emit.next);

      return () => {
        emitter.off("create", emit.next);
      };
    });
  }),
});
