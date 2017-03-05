# Reactive X


----------------------------------------------------------------------------------------------------
##### Introduction

ReactiveX is a library for composing asynchronous and event-based programs by using observable 
sequences.

It extends the observer pattern to support sequences of data and/or events and adds operators that 
allow you to compose sequences together declaratively while abstracting away concerns about things 
like low-level threading, synchronization, thread-safety, concurrent data structures, and non-blocking 
I/O.

Techniques like Futures are straightforward to use for a single level of asynchronous execution but 
they start to add non-trivial complexity when they’re nested. Observables, on the other hand, are 
intended for composing flows and sequences of asynchronous data.

ReactiveX is not biased toward some particular source of concurrency or asynchronicity. Observables 
can be implemented using thread-pools, event loops, non-blocking I/O, actors, or whatever 
implementation suits your needs, your style, or your expertise. 

Client code treats all of its interactions with Observables as asynchronous, whether your underlying 
implementation is blocking or non-blocking and however you choose to implement it. You can later 
change your mind, and radically change the underlying nature of your Observable implementation, 
without breaking the consumers of your Observable.

* [ReactiveX Introduction](http://reactivex.io/intro.html)

----------------------------------------------------------------------------------------------------
##### Principles

1. __Iterables + Iterators__

    * lazy _pull_ based mechanics on a possibly infinite stream.

    * iterables support composable operations

	    ```
	    getDataFromLocalMemory()
	  		.skip(10)
	  		.take(5)
	  		.map({ s -> return s + " transformed" })
	  		.forEach({ println "next => " + it })
		```

2. __Obervables + Observers__

    * generative _push_ based mechanics to generate a possible infinite stream
	
	* an Observable emits items or sends notifications to its observers by calling the Observers’ 
      methods.

	* an Observer __subscribes__ to an Observable. 

	* observables support composable operations

		```
		dataFromNetwork()
	  		.skip(10)
	  		.take(5)
	  		.map({ s -> return s + " transformed" })
	  		.subscribe({ println "onNext => " + it })
		```
		
    * an Observable calls its observer’s __onCompleted__ method to signal the end of a stream
	
	* an Observable calls its observer’s __onError__ method to signal an error end with the stream


3. __Observable / Iterarable Duality__ 

	* an Observable is the asynchronous/push “dual” to the synchronous/pull Iterable

		|event          | Iterable (pull)        | Observable (push)        |
		|---------------|------------------------|--------------------------|
		|retrieve data  | ```T next()```	     | ```onNext(T)```          |
		|discover error | ```throws Exception``` | ```onError(Exception)``` |
		|complete       | ```!hasNext()```       | ```onCompleted()```      |


4. __Operators__

    *  __Higher Order Functions__ (Operators): Filters, Converters, Aggregaators  
    
    * [ReactiveX Operators](http://reactivex.io/documentation/operators.html)


----------------------------------------------------------------------------------------------------
##### Observable

* [ReactiveX Observable](http://reactivex.io/documentation/observable.html)

* [ReactiveX Constract](http://reactivex.io/documentation/contract.html)

1. __Establishing Observers__

	1. __Observer__   : Define method that __onNext__ that _handles_ emitted values.

	2. __Observable__ : Define the asychronous call that __emits__ values to subscribe Observers 
                        by invoking their __onNext__ methods.

	3. __Subscribe__  : Attach the Observer to the Observable by __subscribing__ to it.  


2. __Observer Contract__

	1. __onNext__      : Pass the next emitted __notification__ to the Observer.

	2. __onComplete__  : Indicate no furthur notifications will be emitted.

	3. __onSubscribe__ : __[optional]__ Indicates the Observable is ready to accept __Request__
						 notifications.

	4. __onError__     : Indicate termination with a specified error condition.


3. __Observerable Contract__

	1. __subscribe__   : Indicates the Observer is ready to accept notifications.

	2. __unsubscribe__ : Indicates the Observer no longer wants to receive notifications. 

	3. __request__     : __[optional]__ Idicates the Observer wants to limit the number of 
						 notifications it receives.





----------------------------------------------------------------------------------------------------
##### Operators


----------------------------------------------------------------------------------------------------
##### Single


----------------------------------------------------------------------------------------------------
##### Subject


----------------------------------------------------------------------------------------------------
##### Scheduler


