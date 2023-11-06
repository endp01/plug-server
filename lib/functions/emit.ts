import { EventEmitter } from 'stream'

import { observable } from '@trpc/server/observable'

export const emit = <T>(emitter: EventEmitter, event: string, data: T): T => {
	emitter.emit(event, data)

	return data
}

export const onEmit = <T>(emitter: EventEmitter, event: string) => {
	return observable<T>(emit => {
		emitter.on(event, emit.next)

		return () => emitter.off(event, emit.next)
	})
}
