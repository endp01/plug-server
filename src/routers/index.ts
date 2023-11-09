import permissionRouter from '@/routers/permission'
import { adminProcedure, t } from '@/trpc'

export const appRouter = t.router({
	secretData: adminProcedure.query(({ ctx }) => {
		console.log(ctx.isAdmin)
		return 'Super secret data'
	}),
	permission: permissionRouter
})
