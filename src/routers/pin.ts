import { LivePinSchema } from "@nftchance/plug-types/zod";

import { EventEmitter } from "stream";

import type { LivePin } from "@prisma/client";
import { TRPCError } from "@trpc/server";
import { observable } from "@trpc/server/observable";

import { getLivePairSchema } from "../lib/functions/schema";
import { upsertLivePin } from "../handlers/pin";
import { p } from "../prisma";
import { t } from "../trpc";

const emitter = new EventEmitter();
const procedure = t.procedure;
const schema = getLivePairSchema(LivePinSchema);

export default t.router({
  create: procedure.input(schema).mutation(async (req) => {
    const { domain, message } = req.input;

    // * Add the signed pin object to the database.
    try {
      const { livePin } = await upsertLivePin({
        domain,
        pin: message.pin,
        signature: message.signature,
      });

      emitter.emit("create", livePin);

      return livePin;
    } catch {
      throw new TRPCError({
        code: "BAD_REQUEST",
        message: "Invalid message/signature body provided.",
      });
    }
  }),
  get: procedure.query(async () => {
    return await p.livePin.findMany();
  }),
  onCreate: procedure.subscription(() => {
    return observable<LivePin>((emit) => {
      emitter.on("create", emit.next);

      return () => {
        emitter.off("create", emit.next);
      };
    });
  }),
});
