import { ENVIRONMENTS, METHODS } from '@/lib/constants'

export type EnvironmentKey = keyof typeof ENVIRONMENTS
export type Environment = (typeof ENVIRONMENTS)[EnvironmentKey]

export type APIConfig = {
	apiKey: string
	environmentKey: EnvironmentKey
	pageSize?: number
	logger?: (arg: string) => void
}

export type APIConnection = {
	url: string
	method?: (typeof METHODS)[number]
	headers?: object
}
