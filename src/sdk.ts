import {
	DEFAULT_API_CONFIG,
	DEFAULT_JSON_HEADERS,
	DEFAULT_METHOD,
	DEFAULT_PAGE_SIZE,
	ENVIRONMENTS
} from './lib/constants'
import { APIConfig, APIConnection, Environment } from './lib/types'

export class EmporiumSDK {
	public readonly basePath: Environment

	public pageSize = 20
	public logger: (arg: string) => void

	public readonly apiKey?: string

	constructor(
		config: APIConfig = DEFAULT_API_CONFIG,
		logger?: (arg: string) => void
	) {
		this.apiKey = config.apiKey
		this.basePath = ENVIRONMENTS[config.environmentKey]
		this.pageSize = config.pageSize ?? DEFAULT_PAGE_SIZE
		this.logger = logger ?? ((arg: string) => arg)
	}

	// * Prepare a fetch request with JSON as the request and response type.
	private async _fetchJson(options: APIConnection, body?: string) {
		const response = await fetch(options.url, {
			method: options.method ?? DEFAULT_METHOD,
			headers: {
				...DEFAULT_JSON_HEADERS,
				...options.headers
			},
			body
		})

		if (response.ok) {
			const json = await response.json()

			this.logger(`Response: ${JSON.stringify(json).slice(0, 200)}...`)

			return json
		}

		throw new Error(
			`Request failed with status ${response.status} ${response.statusText}`
		)
	}

	// * Prepare a fetch request with the Emporuim API headers.
	private async _fetch(options: APIConnection, body?: object) {
		const headers = {
			'x-app-id': 'emporium-api-client',
			...(this.apiKey ? { 'X-API-KEY': this.apiKey } : {}),
			...options.headers
		}

		const request = {
			...options,
			headers
		}

		this.logger(
			`Sending request: ${options.url} ${JSON.stringify(request).slice(
				0,
				200
			)}...`
		)

		return await this._fetchJson(
			request,
			body ? JSON.stringify(body) : undefined
		)
	}

	private objectToSearchParams(query: object = {}) {
		const searchParams = new URLSearchParams()

		Object.entries(query).forEach(([key, value]) => {
			if (value && Array.isArray(value)) {
				value.forEach(item => item && searchParams.append(key, item))
			} else if (value) {
				searchParams.append(key, value)
			}
		})

		return searchParams.toString()
	}

	public async get<T>(path: string, query: object = {}): Promise<T> {
		const queryString = this.objectToSearchParams(query)
		const url = `${this.basePath}${path}?${queryString}`

		return await this._fetch({ url })
	}

	// ? "Where's PUT, DELETE" you ask? Well, we don't need them for this project.
	//   Use POST instead and set the proper headers.
	public async post<T>(
		path: string,
		body?: object,
		options?: APIConnection
	): Promise<T> {
		const headers = {
			url: `${this.basePath}${path}`,
			...options
		}

		return await this._fetch(headers, body)
	}
}

export function _throwOrContinue(error: unknown, retries: number) {
	const isUnavailable =
		error instanceof Error &&
		!!error.message &&
		(error.message.includes('503') || error.message.includes('429'))

	if (retries <= 0 || !isUnavailable) {
		throw error
	}
}
