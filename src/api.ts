import cors from 'cors'
import express from 'express'
import ws from 'ws'

import { createExpressMiddleware } from '@trpc/server/adapters/express'
import { applyWSSHandler } from '@trpc/server/adapters/ws'

import { createContext } from '@/context'
import { appRouter } from '@/routers'

const port = 3000
const app = express()

app.use(cors({ origin: 'http://localhost:5173' }))
app.use(
	'/trpc',
	createExpressMiddleware({
		router: appRouter,
		createContext
	})
)

const server = app.listen(port, () =>
	console.log(`Emporium API server running on port: ${port}`)
)

applyWSSHandler({
	wss: new ws.Server({ server }),
	router: appRouter,
	createContext
})

export type AppRouter = typeof appRouter
