import { z } from 'zod'

import { EmporiumSDK } from '@/sdk'

const ENVIRONMENT_VARIABLES_SCHEMA = z.object({
	DEBUG: z.boolean().optional().default(false),
	API_KEY: z.string().optional().default(''),
	PORT: z.number().optional().default(8000)
})

const ENVIRONMENT_VARIABLES = ENVIRONMENT_VARIABLES_SCHEMA.parse(process.env)

export const DEFAULT_URL = 'localhost:3000/trpc'
export const ENVIRONMENTS = {
	DEVELOPMENT: `http://localhost:${ENVIRONMENT_VARIABLES.PORT}/`,
	PRODUCTION: 'https://api.emporium.com/'
} as const

export const DEFAULT_ENVIRONMENT: keyof typeof ENVIRONMENTS =
	ENVIRONMENT_VARIABLES.DEBUG ? 'DEVELOPMENT' : 'PRODUCTION'
export const DEFAULT_PAGE_SIZE = 20
export const DEFAULT_API_CONFIG = {
	apiKey: ENVIRONMENT_VARIABLES.API_KEY,
	environmentKey: DEFAULT_ENVIRONMENT,
	pageSize: 20
}
export const DEFAULT_API = new EmporiumSDK(DEFAULT_API_CONFIG)

export const METHODS = ['GET', 'POST', 'PUT', 'DELETE'] as const
export const DEFAULT_METHOD: (typeof METHODS)[number] = 'GET' as const
export const DEFAULT_CONTENT_TYPE = 'application/json' as const
export const DEFAULT_JSON_HEADERS = {
	Accept: DEFAULT_CONTENT_TYPE,
	'Content-Type': DEFAULT_CONTENT_TYPE
} as const
