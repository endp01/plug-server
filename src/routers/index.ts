import { adminProcedure, t } from '../trpc'

import permissionRouter from '../routers/permission'
import intentsRouter from '../routers/intents'

export const appRouter = t.router({
	secretData: adminProcedure.query(({ ctx }) => {
		console.log(ctx.isAdmin)
		return 'Super secret data'
	}),
	permission: permissionRouter,
	intents: intentsRouter
})
