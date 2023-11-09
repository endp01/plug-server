import {
	createTRPCProxyClient,
	createWSClient,
	httpBatchLink,
	splitLink,
	wsLink
} from '@trpc/client'

import { AppRouter } from './api'
import { DEFAULT_URL } from './lib/constants'

export const getConnector = (url: string = DEFAULT_URL) => { 
    // * This is defined in the server package because trpc/client & trpc/server may be conflicting sometimes and it 
    //   is not exactly straightforward to determine that the packages are simply out of sync.
    //
    //   If you ever update trpc/server (or client) and `AppRouter` randomly stops working, check this file first.
    //   It is likely that you just need to update the packages to work on a version that is compatible. Do note, 
    //   that just because the version numbers are the same, does not mean that they are compatible. 
    return createTRPCProxyClient<AppRouter>({
        links: [
            splitLink({
                condition: op => {
                    return op.type === 'subscription'
                },
                true: wsLink({
                    client: createWSClient({
                        url: `ws://${url}`
                    })
                }),
                false: httpBatchLink({
                    url: `http://${url}`
                })
            })
        ]
    })
}

// export const connector = getConnector()