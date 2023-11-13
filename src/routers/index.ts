import { adminProcedure, t } from "../trpc";

import pinRouter from "../routers/pin";
import plugsRouter from "../routers/plugs";

export const appRouter = t.router({
  secretData: adminProcedure.query(({ ctx }) => {
    console.log(ctx.isAdmin);
    return "Super secret data";
  }),
  pin: pinRouter,
  plugs: plugsRouter,
});
