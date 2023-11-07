import { adminProcedure, t } from '@/trpc'
import permissionsRouter from '@/routers/permission'

export const appRouter = t.router({
	secretData: adminProcedure.query(({ ctx }) => {
		console.log(ctx.isAdmin)
		return 'Super secret data'
	}),
	permissions: permissionsRouter
})
